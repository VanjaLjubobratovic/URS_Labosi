#include <avr/io.h>
#include <avr/interrupt.h>

ISR(TIMER1_COMPA_vect) {
    PORTA = PORTA << 1;
    PORTA += 0x01;

    if (PORTA == 0xff) {
        PORTA = 0xfe;
    }
}

int main(void) {
    DDRA = 0xff;
    PORTA = 0xff;

    TCCR1A = 0x00;
    TCCR1B = _BV(WGM12) | _BV(CS11) | _BV(CS10);
    OCR1A = 25343;

    TIMSK = _BV(OCIE1A);
    sei();

    while (1);
}
