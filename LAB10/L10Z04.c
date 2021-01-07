#define F_CPU 7372800UL

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include <stdlib.h>

#include "lcd.h"

void writeLCD(uint16_t adc) {
    lcd_clrscr();

    char adcStr[16];
    itoa(adc, adcStr, 10);
    lcd_puts(adcStr);
}

ISR(ADC_vect) {
    uint16_t temp = ((ADC * 5.0/1024) - 0.5) * 1000/10;

    writeLCD(temp);
}

int main(void) {
    DDRD = _BV(4);

    TCCR1A = _BV(COM1B1) | _BV(WGM10);
    TCCR1B = _BV(WGM12) | _BV(CS11);
    OCR1B = 64;

    lcd_init(LCD_DISP_ON);

    ADMUX = _BV(REFS0);
    ADCSRA = _BV(ADEN) | _BV(ADIE) | _BV(ADPS2) | _BV(ADPS1);

    sei();

    while (1) {
        ADCSRA |= _BV(ADSC);

        _delay_ms(1000);
    }
}
