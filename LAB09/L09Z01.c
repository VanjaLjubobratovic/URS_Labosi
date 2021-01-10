#define F_CPU 7372800UL

#include <avr/io.h>
#include <util/delay.h>

uint16_t time = 0;
uint8_t data[4];
uint8_t dotOn = 0;

void time2data(uint16_t time, uint8_t data[]) {
    uint8_t i;
    for (i = 0; i < 4; i++) {
        data[3 - i] = time % 10;
        time /= 10;
    }
}

int main() {
    DDRA = 0xff;
    DDRB = 0xf0;

    uint8_t values[] = {0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x6f};
    uint8_t i;

    time2data(8888, data);
    dotOn = 1;

    while (1) {
        for (i = 0; i < 4; i++) {
	    // sljedeće linije služe za čišćenje stanja (bolja vidljivost segmenata)
	    PORTA = 0;
	    PORTB = _BV(4 + i);
	    _delay_ms(1);
		
            PORTA = values[data[i]];

            if (dotOn) {
                PORTA |= _BV(7);
            }

            PORTB = _BV(4 + i);
            _delay_ms(1);
        }
    }
}
