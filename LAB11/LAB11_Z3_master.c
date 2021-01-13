


#define F_CPU 7372800UL					/* Define CPU Frequency e.g. here its 8MHz */
#include <avr/io.h>						/* Include AVR std. library file */
#include <util/delay.h>					/* Include Delay header file */
#include <stdio.h>
#include <string.h>
#include "lcd.h"			/* Include LCD header file */
#include "SPI_Master_H_file.h"			/* Include SPI master header file */

int main(void)
{
	DDRD = _BV(4);

	TCCR1A = _BV(COM1B1) | _BV(WGM10);
	TCCR1B = _BV(WGM12) | _BV(CS11);
	OCR1B = 18;
	uint8_t count;
	
	char buffer[5];
	
	lcd_init(LCD_DISP_ON);
	SPI_Init();
	
	lcd_gotoxy(0, 0);
	lcd_puts("Master Device");
	lcd_gotoxy(0, 1);
	lcd_puts("Sending:");
	
	SS_Enable;
	count = 0;
	
	while (1)
	{
		SPI_Write(count);
		sprintf(buffer,"%d", count);
		lcd_gotoxy(13, 1);
		lcd_puts(buffer);
		count++;
		_delay_ms(500);
	}
}