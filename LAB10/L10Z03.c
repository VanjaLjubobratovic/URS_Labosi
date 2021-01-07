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
    writeLCD(ADC);

    // Opcija 1: Rucno pokretanje sljedece konverzije
    ADCSRA |= _BV(ADSC);
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

    // Opcija 1: Rucno pokretanje prve konverzije
    ADCSRA |= _BV(ADSC);

    while (1) {
        // Opcija 2: Rucno pokretanje svake konverzije
        // ADCSRA |= _BV(ADSC);

        // _delay_ms(1000);
    }
}
