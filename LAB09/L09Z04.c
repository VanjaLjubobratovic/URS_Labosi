#define F_CPU 7372800UL

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

static uint16_t time = 0;
static uint8_t data[4];
static uint8_t dotOn[4];
static uint8_t fStop = 1;
static uint8_t debounce = 0;
static uint8_t fDate = 0;
static uint16_t dateTime = 0;

void time2data(uint16_t time, uint8_t data[]) {
    uint8_t i;
    for (i = 0; i < 4; i++) {
        data[3 - i] = time % 10;
        time /= 10;
    }
}

ISR(TIMER1_COMPA_vect) {
    if (!fStop) {
        time = (time >= 10000) ? 0 : time + 1;
        dotOn[1] = !(time % 50) ? ~dotOn[1] : dotOn[1];
        time2data(time, data);
    }

    if (fDate) {
        dateTime++;
        if (dateTime <= 500) {
            data[0] = 0; dotOn[0] = 0;
            data[1] = 1; dotOn[1] = 1;
            data[2] = 1; dotOn[2] = 0;
            data[3] = 1; dotOn[3] = 1;
        } else if (dateTime <= 1000) {
            data[0] = 1; dotOn[0] = 0;
            data[1] = 9; dotOn[1] = 0;
            data[2] = 9; dotOn[2] = 0;
            data[3] = 1; dotOn[3] = 1;
        } else {
            dateTime = 0;
            fDate = 0;
        }
    }
}

ISR(INT0_vect) {
    fDate = 1;
}

int main() {
    uint8_t values[] = {0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x6f};
    uint8_t i;

    DDRA = 0xff;
    PORTB = _BV(0) | _BV(1);
    DDRB = 0xf0;

    for (i = 0; i < 4; i++) {
        data[i] = 0;
        dotOn[i] = 0;
    }

    TCCR1A = 0;
    TCCR1B = _BV(WGM12) | _BV(CS11);
    OCR1A = 9216;

    TIMSK = _BV(OCIE1A);

    MCUCR = _BV(ISC01);
    GICR = _BV(INT0);
    sei();

    while (1) {
        for (i = 0; i < 4; i++) {
            PORTA = values[data[i]];

            if (dotOn[i]) {
                PORTA |= _BV(7);
            }

            PORTB = (PORTB & 0x0f) | _BV(4 + i);
            _delay_ms(1);;
            if (debounce) debounce--;
        }

        if (!debounce && bit_is_clear(PINB, 0)) {
            fStop ^= 1;
            debounce = 200;
        } else if (bit_is_clear(PINB, 1)) {
            time = 0;
            time2data(time, data);
        }

    }
}
