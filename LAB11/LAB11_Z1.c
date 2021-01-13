// One-wire serial interface
#define F_CPU 7372800UL
#include <util/delay.h>
#include <avr/io.h>
#include <stdlib.h>
#include <stdio.h>
#include "lcd.h"
#define DHT11_PIN 6

uint8_t c = 0, integralRh, decimalRh, integralTemp, decimalTemp, checksum;

void Request()						/* Microcontroller send start pulse or request */
{
	DDRD |= _BV(DHT11_PIN);			// Request is sent from MCU PIN
	PORTD |= _BV(DHT11_PIN);
	PORTD &= ~_BV(DHT11_PIN);		/* set to low pin, pull down */
	_delay_ms(20);					/* wait for 20ms */
	PORTD |= _BV(DHT11_PIN);		/* set to high pin, pull up */
}

void Response()						/* receive response from DHT11 */
{
	DDRD &= ~_BV(DHT11_PIN); // explicitly pull up PIN
 	while(PIND & _BV(DHT11_PIN)); // check to see if state changed from high to low
	while((PIND & _BV(DHT11_PIN)) == 0); // check if pulled down voltage is equal to zero
	while(PIND & _BV(DHT11_PIN)); // check to see if state change from low to high
}

uint8_t Receive_data()							/* receive data */
{	
	/*
	The data frame is of total 40 bits long, it contains 5 segments and each segment
	is 8-bit long. We check each bit if it is high or low
	*/
	for (uint8_t q=0; q<8; q++) {
		while((PIND &  _BV(DHT11_PIN)) == 0);/* check received bit 0 or 1, if pulled up */
		_delay_us(60);
		/* if high pulse is greater than 30ms */
		if(PIND & _BV(DHT11_PIN)) {
			/* then it is logic HIGH */
			c = (c << 1) | (0x01);
		} else {
			/* otherwise it is logic LOW */
			c = (c << 1);
		}								
		while(PIND & _BV(DHT11_PIN));
	}
	return c;
}

int main(void)
{	
	DDRD = _BV(4);

	TCCR1A = _BV(COM1B1) | _BV(WGM10);
	TCCR1B = _BV(WGM12) | _BV(CS11);
	OCR1B = 24;
	
	char messageString[16];
	lcd_init(LCD_DISP_ON);
	lcd_clrscr();	
	
	// ensure that sensor is stabilised
	_delay_ms(1000);		
	
    while(1)
	{	
		Request();				/* send start pulse */
		Response();				/* receive response */
		integralRh = Receive_data();	/* store first eight bit in integralRh */
		decimalRh = Receive_data();	/* store next eight bit in decimalRh */
		integralTemp = Receive_data();	/* store next eight bit in integralTemp */
		decimalTemp = Receive_data();	/* store next eight bit in decimalTemp */
		checksum = Receive_data();/* store next eight bit in checksum */
		
		if ((integralRh + decimalRh + integralTemp + decimalTemp) != checksum) {
			lcd_gotoxy(0,0);
			lcd_puts("Error");
		} else {
			sprintf(messageString, "Humidity: %2d.%1d %%", integralRh, decimalRh);
			lcd_gotoxy(0, 0);
			lcd_puts(messageString);
			
			sprintf(messageString, "Temp: %2d.%1d %cC", integralTemp, decimalTemp, 223);
			lcd_gotoxy(0, 1);
			lcd_puts(messageString);
		}
				
		_delay_ms(500);
	}	
}
