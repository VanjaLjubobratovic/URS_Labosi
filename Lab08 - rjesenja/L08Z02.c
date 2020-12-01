#include <avr/io.h>
#include <avr/interrupt.h>

#include "lcd.h"

static uint8_t tSS = 0;
static uint8_t tS = 0;
static uint8_t tM = 0;
static uint8_t tH = 0;

void changeTime() {
    char time[9];

    time[0] = '0' + (tH / 10);
    time[1] = '0' + (tH % 10);
    time[2] = ':';
    time[3] = '0' + (tM / 10);
    time[4] = '0' + (tM % 10);
    time[5] = ':';
    time[6] = '0' + (tS / 10);
    time[7] = '0' + (tS % 10);
    time[8] = '\0';

    lcd_clrscr();
    lcd_gotoxy(4, 0);
    lcd_puts(time);
}

ISR(TIMER0_COMP_vect) {
    tSS++;

    if (tSS == 100) {
        tSS = 0;

        tS++;
        if (tS == 60) {
            tS = 0;
            tM++;
        }
        if (tM == 60) {
            tM = 0;
            tH++;
        }
        if (tH == 24) {
            tH = 0;
        }

        changeTime();
    }
}

int main(void)
{
    DDRD = _BV(4);

    TCCR1A = _BV(COM1B1) | _BV(WGM10);
    TCCR1B = _BV(WGM12) | _BV(CS11);
    OCR1B = 128;

    TCCR0 = _BV(WGM01) | _BV(CS02) | _BV(CS00);
    OCR0 = 72;

    TIMSK = _BV(OCIE0);
    sei();

    lcd_init(LCD_DISP_ON);
    lcd_clrscr();

    while (1);
}
