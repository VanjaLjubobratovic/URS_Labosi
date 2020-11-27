#define F_CPU 7372800UL

#include <avr/io.h>
#include <util/delay.h>

void turnOn(void) {
    if (!PORTA) {
        PORTA = 0xff;
    } else {
        PORTA = PORTA >> 1;
    }
}

int main(void) {
    DDRA = 0xff;
    PORTA = 0xff;

    while (1) {
        turnOn();
        _delay_ms(250);
    }
}

