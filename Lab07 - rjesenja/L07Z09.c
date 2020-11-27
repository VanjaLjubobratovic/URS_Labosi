#define F_CPU 7372800UL

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

static uint16_t timeout = 1000;
static uint16_t step = 50;
static uint16_t top = 5000;

void delay(uint16_t timeout) {
    uint16_t i;
    for(i = 0; i < timeout; i++) {
        _delay_ms(1);
    }
}

void runLeds() {
    PORTA = PORTA << 1;
    PORTA += 0x01;

    if (PORTA == 0xff) {
        PORTA = 0xfe;
    }
}

ISR(INT0_vect) {
    if (timeout > step) {
        timeout -= step;
    }
}

ISR(INT1_vect) {
    if (timeout < top - step) {
        timeout += step;
    }
}

int main(void) {
    DDRA = 0xff;
    PORTA = 0xff;

    MCUCR = _BV(ISC01) | _BV(ISC11);
    GICR = _BV(INT0) | _BV(INT1);
    sei();

    while(1) {
        runLeds();
        delay(timeout);
    }
}
