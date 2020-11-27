#define F_CPU 7372800UL

#include <avr/io.h>
#include <util/delay.h>

uint8_t reverse_byte(uint8_t in) {
    uint8_t out = 0;
    uint8_t i;

    for (i = 0; i < 8; i++) {
        out = (out << 1) + (in & 0x01);
        in = in >> 1;
    }

    return out;
}

void step(void) {
    uint8_t pos;

    pos = reverse_byte(~PORTA);

    if (PORTA == 0xff) {
        pos = 0x01;
    } else if ((~PORTA & 0x0f) == 0x00) {
        pos = (pos << 1) & 0x0f;
    }

    PORTA = ~pos;
}

int main(void) {
    DDRA = 0xff;
    PORTA = 0xff;

    while (1) {
        _delay_ms(333);
        step();
    }
}

