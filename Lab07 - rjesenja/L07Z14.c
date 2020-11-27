#include <avr/io.h>
#include <avr/interrupt.h>

ISR(TIMER1_COMPA_vect) {
    PORTA ^= _BV(0);
}

int main(void) {
    DDRA = _BV(0);
    PORTA = _BV(0);

    TCCR1A = _BV(WGM11) | _BV(WGM10);
    TCCR1B = _BV(CS10);
    OCR1A = 895;

    TIMSK = _BV(OCIE1A);
    sei();

    while (1);
}
