#define F_CPU 7372800UL

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

static uint16_t time = 0;
static uint8_t data[4];
static uint8_t dotOn = 0;

void time2data(uint16_t time, uint8_t data[]) {
    uint8_t i;
    for (i = 0; i < 4; i++) {
        data[3 - i] = time % 10;
        time /= 10;
    }
}

ISR(TIMER1_COMPA_vect) {
    time = (time >= 10000) ? 0 : time + 1;
    dotOn = !(time % 50) ? ~dotOn : dotOn;

    time2data(time, data);
}

int main() {
    DDRA = 0xff;
    DDRB = 0xf0;

    uint8_t values[] = {0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x6f};
    uint8_t i;

    TCCR1A = 0;
    TCCR1B = _BV(WGM12) | _BV(CS11);
    OCR1A = 9216;

    TIMSK = _BV(OCIE1A);
    sei();

    while (1) {
        for (i = 0; i < 4; i++) {
	    PORTA = 0;
	    PORTB = _BV(4 + i);
	    _delay_ms(1);

            PORTA = values[data[i]];

            if (i == 1 && dotOn) {
                PORTA |= _BV(7);
            }

            PORTB = _BV(4 + i);
            _delay_ms(1);
        }
    }
}
