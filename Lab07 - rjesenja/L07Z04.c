#define F_CPU 7372800UL

#include <avr/io.h>
#include <util/delay.h>

void delay(uint16_t timeout) {
    uint16_t i;
    for(i = 0; i < timeout; i++) {
        _delay_ms(1);
    }
}

void blink(uint8_t led) {
    PORTA ^= _BV(led);
}

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

    PORTB = _BV(0) | _BV(1) | _BV(2);
    DDRB = 0x00;

    uint8_t flag = 0;
    uint16_t timeout = 100;

    while (1) {
        if(bit_is_clear(PINB, 0)) {
            flag = 1;
            timeout = 100;
            PORTA |= ~_BV(3);
        } else if(bit_is_clear(PINB, 1)) {
            flag = 2;
            timeout = 250;
            PORTA = 0xff;
        } else if(bit_is_clear(PINB, 2)) {
            flag = 3;
            timeout = 100;
            PORTA |= ~_BV(0);
        }

        switch(flag) {
            case 1:
                blink(3);
                break;
            case 2:
                turnOn();
                break;
            case 3:
                blink(0);
                flag = 0;
                break;
        }

        delay(timeout);
    }
}

