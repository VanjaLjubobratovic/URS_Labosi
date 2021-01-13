#define F_CPU 7372800UL
#include <stdlib.h>
#include <string.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <string.h>
#include <stdio.h>
#include <math.h>

#include "I2C_Master_H_file.h"
#include "bmp280.h"
#include "lcd.h"

uint16_t temperature, pressure;

void lcd_show_temp(uint16_t temperature) {
	uint16_t tempVal = temperature / 100;
	uint16_t tempDecimal = temperature % 10;
	char tempStr[16];
	// 223 is ascii for ?
	sprintf(tempStr, "Temp: %2d.%1d %c C", tempVal, tempDecimal, 223);
	lcd_gotoxy(0, 0);
	lcd_puts(tempStr);
}

void lcd_show_pressure(uint16_t pressure) {
	uint16_t pressureVal = pressure / 1000;
	uint16_t pressureDec = pressure % 10;
	char presStr[16];
	sprintf(presStr, "Pressure: %2d.%1d Hg", pressureVal, pressureDec);
	lcd_gotoxy(0, 1);
	lcd_puts(presStr);
}

int main(void) {
	DDRD = _BV(4);

	TCCR1A = _BV(COM1B1) | _BV(WGM10);
	TCCR1B = _BV(WGM12) | _BV(CS11);
	OCR1B = 24;

	lcd_init(LCD_DISP_ON);
	lcd_clrscr();
	
	bmp280_init(); // i2c_init() function is called from bmp280_init()

	// enable IRQs
	sei();


	while(1) {
		bmp280_measure();
		
		temperature = bmp280_gettemperature();
		lcd_show_temp(temperature);
		
		pressure = bmp280_getpressure();
		lcd_show_pressure(pressure);
		
		_delay_ms(500);
	}
	return 0;
}