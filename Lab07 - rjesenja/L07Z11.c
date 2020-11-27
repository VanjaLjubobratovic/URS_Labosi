#include <avr/io.h>
#include <avr/interrupt.h>

ISR(TIMER1_COMPA_vect) {
    PORTA ^= _BV(0);
}

int main(void) {
    DDRA = _BV(0);
    PORTA = _BV(0);

    TCCR1A = 0x00;
    TCCR1B = _BV(WGM12) | _BV(CS11) | _BV(CS10);
    OCR1A = 11519;

    TIMSK = _BV(OCIE1A);
    sei();

    while (1);
}
