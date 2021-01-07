#define F_CPU 7372800UL

#include <avr/io.h>
#include <util/delay.h>
#include <stdlib.h>

#include "lcd.h"

void writeLCD(uint16_t adc) {
    lcd_clrscr();

    char adcStr[16];
    itoa(adc, adcStr, 10);
    lcd_puts(adcStr);
}

int main(void)
{
    DDRD = _BV(4);

    TCCR1A = _BV(COM1B1) | _BV(WGM10);
    TCCR1B = _BV(WGM12) | _BV(CS11);
    OCR1B = 64;

    lcd_init(LCD_DISP_ON);

    ADMUX = _BV(REFS0);
    ADCSRA = _BV(ADEN) | _BV(ADPS2) | _BV(ADPS1);

    while (1) {
        ADCSRA |= _BV(ADSC);

        while (!(ADCSRA & _BV(ADIF)));

        writeLCD(ADC);

        _delay_ms(100);
    }
}
