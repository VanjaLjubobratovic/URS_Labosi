#include <avr/io.h>
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
    writeLCD(ADC);
}

int main(void)
{
    DDRD = _BV(4);

    TCCR1A = _BV(COM1B1) | _BV(WGM10);
    TCCR1B = _BV(WGM12) | _BV(CS11);
    OCR1B = 64;

    lcd_init(LCD_DISP_ON);

    TCCR0 = _BV(WGM01) | _BV(CS02) | _BV(CS00);
    OCR0 = 180;

    TIMSK = _BV(OCIE0);

    ADMUX = _BV(REFS0);
    ADCSRA = _BV(ADEN) | _BV(ADATE) | _BV(ADIE) | _BV(ADPS2) | _BV(ADPS1);
    SFIOR = _BV(ADTS1) | _BV(ADTS0);

    sei();

    while (1);
}
