.def tmp = r16
.def mask = r17

.cseg
    rjmp reset

.org $00C
    rjmp dimLed

reset:
    ldi tmp, high(RAMEND)
    out SPH, tmp
    ldi tmp, low(RAMEND)
    out SPL, tmp

    ldi mask, (1 << PA0)
    out DDRA, mask
    out PORTA, mask

    ; 10 bit Phase correct PWM
    ldi tmp, (1 << WGM11) | (1 << WGM10)
    out TCCR1A, tmp

    ldi tmp, (1 << CS10)
    out TCCR1B, tmp

    ldi tmp, high(102)
    out OCR1AH, tmp
    ldi tmp, low(102)
    out OCR1AL, tmp

    ldi tmp, (1 << OCIE1A)
    out TIMSK, tmp

    sei

main:
rjmp main

dimLed:
    in tmp, PORTA
    eor tmp, mask
    out PORTA, tmp
reti
