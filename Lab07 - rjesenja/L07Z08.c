#define F_CPU 7372800UL

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

void debounce() {
    _delay_ms(100);
    GIFR = _BV(INTF0) | _BV(INTF1);
}

ISR(INT0_vect) {
    PORTA = PORTA << 1;

    debounce();
}

ISR(INT1_vect) {
    PORTA = PORTA >> 1;
    PORTA |= 0x80;

    debounce();
}

int main(void) {
    DDRA = 0xff;
    PORTA = 0xff;

    MCUCR = _BV(ISC01) | _BV(ISC11);
    GICR = _BV(INT0) | _BV(INT1);
    sei();

    while(1);
}
