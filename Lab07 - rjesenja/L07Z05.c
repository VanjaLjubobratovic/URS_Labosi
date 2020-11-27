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

    pos = ~PORTA & 0x0f;

    // Choosing direction
    static uint8_t flag = 0;
    if (pos == 0x0f) {
        flag = 1;
    } else if (pos == 0x00) {
        flag = 0;
    }

    // Rotating half byte
    if (!flag) {
        pos = (pos << 1) + 0x01;
    } else {
        pos = (pos >> 1);
    }

    PORTA = ~(pos | reverse_byte(pos));
}

int main(void) {
    DDRA = 0xff;
    PORTA = 0xff;

    while (1) {
        _delay_ms(325);
        step();
    }
}

