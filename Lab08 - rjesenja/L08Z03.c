#define F_CPU 7372800UL

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include <string.h>

#include "lcd.h"

static uint8_t tSS = 0;
static uint8_t tS = 0;
static uint8_t tM = 0;
static uint8_t tH = 0;

static uint8_t fMode = 0;

static uint8_t fClockSet = 0;
const char *clockSet[4];

static uint8_t fColor = 0;
const char *color[4];

void showTime() {
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

    lcd_gotoxy(4, 0);
    lcd_puts(time);
}

void showMsg() {
    lcd_clrscr();
    lcd_puts_P("Hello World");
}

void showMode() {
    char mode[3];
    mode[0] = 'f';
    mode[1] = '1' + fMode;
    mode[2] = '\0';

    lcd_gotoxy(0,1);
    lcd_puts(mode);

    switch (fMode) {
        case 1:
        lcd_gotoxy(16 - strlen(clockSet[fClockSet]), 1);
        lcd_puts(clockSet[fClockSet]);
        break;
        case 2:
        lcd_gotoxy(13, 1);
        uint8_t dc = 100 - OCR1B * 100 / 256;
        char dc_string[4];
        dc_string[0] = '0' + dc / 10;
        dc_string[1] = '0' + dc % 10;
        dc_string[2] = '%';
        dc_string[3] = '\0';

        lcd_puts(dc_string);
        break;
        case 3:
        lcd_gotoxy(16 - strlen(color[fColor]), 1);
        lcd_puts(color[fColor]);
        break;
    }
}

void writeOnLCD() {
    lcd_clrscr();

    if (!fMode) {
        showMsg();
        } else {
        showTime();
    }

    showMode();
}

void changeColor() {
    PORTA = (PORTA & 0x0f);
    if (fColor) {
        PORTA |= _BV(4 + fColor);
    }

    writeOnLCD();
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

        writeOnLCD();
    }
}

void nonBlockingDebounce() {
    GICR &= ~_BV(INT0);
    sei();

    _delay_ms(500);
    GIFR = _BV(INTF0);
    GICR |= _BV(INT0);

    cli();
}

ISR(INT0_vect) {
    fMode = (fMode+1) % 4;

    writeOnLCD();

    nonBlockingDebounce();
}

int main(void)
{
    clockSet[0] = "";
    clockSet[1] = "Hours";
    clockSet[2] = "Minutes";
    clockSet[3] = "Seconds";

    color[0] = "No color";
    color[1] = "Red";
    color[2] = "Green";
    color[3] = "Blue";

    DDRA = _BV(5) | _BV(6) | _BV(7);
    PORTB = _BV(0) | _BV(1) | _BV(2);
    DDRB = 0;

    DDRD = _BV(4);

    TCCR1A = _BV(COM1B1) | _BV(WGM10);
    TCCR1B = _BV(WGM12) | _BV(CS11);
    OCR1B = 128;

    TCCR0 = _BV(WGM01) | _BV(CS02) | _BV(CS00);
    OCR0 = 72;

    TIMSK = _BV(OCIE0);

    MCUCR = _BV(ISC01);
    GICR = _BV(INT0);
    sei();

    lcd_init(LCD_DISP_ON);
    lcd_clrscr();

    writeOnLCD();

    while (1) {
        if (bit_is_clear(PINB, 0)) {
            switch (fMode) {
                case 1:
                fClockSet = (fClockSet + 1) % 4;
                break;
                case 2:
                OCR1B = (OCR1B < 250) ? OCR1B + 5 : OCR1B;
                break;
                case 3:
                fColor = (fColor + 1) % 4;
                changeColor();
                break;
            }
            } else if (bit_is_clear(PINB, 1)) {
            switch (fMode) {
                case 1:
                switch (fClockSet) {
                    case 1:
                    tH = (tH + 1) % 24;
                    break;
                    case 2:
                    tM = (tM + 1) % 60;
                    break;
                    case 3:
                    tS = (tS + 1) % 60;
                    break;
                }
                break;
                case 2:
                OCR1B = (OCR1B > 5) ? OCR1B - 5 : OCR1B;
                break;
                case 3:
                fColor = (fColor + 3) % 4;
                changeColor();
                break;
            }
            } else if (bit_is_clear(PINB, 2)) {
            switch (fMode) {
                case 1:
                switch (fClockSet) {
                    case 1:
                    tH = (tH + 23) % 24;
                    break;
                    case 2:
                    tM = (tM + 59) % 60;
                    break;
                    case 3:
                    tS = (tS + 59) % 60;
                    break;
                }
                break;
            }
        }

        _delay_ms(200);
    }
}
