#include <avr/io.h>

int main(void) {
    DDRD = _BV(5);

    TCCR1A = _BV(COM1A0);
    TCCR1B = _BV(WGM12) | _BV(CS11) | _BV(CS10);
    OCR1A = 28799;

    while (1);
}
