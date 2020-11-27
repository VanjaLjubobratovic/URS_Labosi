#define F_CPU 7372800UL

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

static uint16_t timeout = 10;
static int8_t activity = 0;

void delay(uint16_t timeout) {
    uint16_t i;
    for(i = 0; i < timeout; i++) {
        _delay_ms(1);
    }
}

uint8_t reverse_byte(uint8_t in) {
    uint8_t out = 0;
    uint8_t i;

    for (i = 0; i < 8; i++) {
        out = (out << 1) + (in & 0x01);
        in = in >> 1;
    }

    return out;
}

void debounce() {
    _delay_ms(200);
    GIFR = _BV(INTF0) | _BV(INTF1);
}

ISR(INT0_vect) {
    if (activity == 1 || activity == -1) {
        activity *= -1;
    } else {
        PORTA = 0xff;
        activity = 1;
        timeout = 325;
    }

    debounce();
}

ISR(INT1_vect) {
    if (activity == 2 || activity == -2) {
        activity *= -1;
    } else {
        PORTA = 0xff;
        activity = 2;
        timeout = 325;
    }

    debounce();
}

void act1(void) {
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

void act2(void) {
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

    MCUCR = _BV(ISC01) | _BV(ISC11);
    GICR = _BV(INT0) | _BV(INT1);
    sei();

    while(1) {
        delay(timeout);
        switch (activity) {
            case 1:
                act1();
                break;
            case 2:
                act2();
                break;
        }
    }
}
