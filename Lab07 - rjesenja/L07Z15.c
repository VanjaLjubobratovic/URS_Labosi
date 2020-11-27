#include <avr/io.h>
#include <avr/interrupt.h>

static uint16_t step = 4;
static uint16_t top = 255;

ISR(TIMER1_COMPA_vect) {
    PORTA = _BV(0);
}

ISR(TIMER1_OVF_vect) {
    PORTA = 0x00;
}

ISR(INT0_vect) {
    if (OCR1A < top - step) {
        OCR1A += step;
    }
}

ISR(INT1_vect) {
    if (OCR1A > step) {
        OCR1A -= step;
    }
}

int main(void) {
    DDRA = _BV(0);
    PORTA = _BV(0);

    TCCR1A = _BV(WGM10);
    TCCR1B = _BV(WGM12) | _BV(CS11) | _BV(CS10);
    OCR1A = 128;

    TIMSK = _BV(OCIE1A) | _BV(TOIE1);

    MCUCR = _BV(ISC01) | _BV(ISC11);
    GICR = _BV(INT1) | _BV(INT0);
    sei();

    while (1);
}
