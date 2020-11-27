#define F_CPU 7372800UL

#include <avr/io.h>
#include <util/delay.h>

void blink(void) {
    PORTA ^= _BV(3);
}

int main(void) {
    DDRA = _BV(3);
    PORTA = _BV(3);

    while (1) {
        blink();
        _delay_ms(100);
    }
}

