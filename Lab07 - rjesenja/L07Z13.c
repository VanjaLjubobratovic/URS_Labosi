#include <avr/io.h>

int main(void) {
    DDRD = _BV(4);

    TCCR1A = _BV(COM1B1) | _BV(COM1B0) | _BV(WGM11) | _BV(WGM10);
    TCCR1B = _BV(WGM13) | _BV(WGM12) | _BV(CS11);
    OCR1A = 46079;
    OCR1B = 23040;

    while (1);
}
