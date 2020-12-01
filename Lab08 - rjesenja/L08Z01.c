#include <avr/io.h>

#include "lcd.h"

int main(void)
{
    DDRD = _BV(4);

    TCCR1A = _BV(COM1B1) | _BV(WGM10);
    TCCR1B = _BV(WGM12) | _BV(CS11);
    OCR1B = 128;

    lcd_init(LCD_DISP_ON);
    lcd_clrscr();
    lcd_puts("Hello World");

    while (1);
}
