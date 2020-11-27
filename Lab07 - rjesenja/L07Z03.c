#define F_CPU 7372800UL

#include <avr/io.h>
#include <util/delay.h>

void blink(void) {
    PORTA ^= _BV(0);
}

int main(void) {
    DDRA = _BV(0);
    PORTA = _BV(0);

    PORTB = _BV(0);
    DDRB = 0;

    while (1) {
        if(bit_is_clear(PINB, 0)) {
            blink();
        }

        // Debounce cekanjem
        _delay_ms(200);
    }
}

