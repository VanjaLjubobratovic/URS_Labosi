.def tmp = r16
.def mask = r17
.def cnt = r18
.def step = r19

.cseg
    rjmp reset

.org $002
    rjmp incDC

.org $004
    rjmp decDC

.org $00C
    rjmp dimLed

.org $010
    rjmp dimLed

reset:
    ldi tmp, high(RAMEND)
    out SPH, tmp
    ldi tmp, low(RAMEND)
    out SPL, tmp

    ldi tmp, (1 << PA0)
    out DDRA, tmp

    ldi tmp, (1 << PA0)
    out PORTA, tmp

    ldi mask, (1 << PA0)
    ldi step, 0x04

    ldi tmp, (1 << WGM10)
    out TCCR1A, tmp

    ldi tmp, (1 << WGM12) | (1 << CS11) | (1 << CS10)
    out TCCR1B, tmp

    ldi tmp, high(128)
    out OCR1AH, tmp
    ldi tmp, low(128)
    out OCR1AL, tmp

    ldi tmp, (1 << OCIE1A) | (1 << TOIE1)
    out TIMSK, tmp

    ldi tmp, (1 << ISC01) | (1 << ISC11)
    out MCUCR, tmp

    ldi tmp, (1 << INT1) | (1 << INT0)
    out GICR, tmp

    sei

main:
rjmp main

dimLed:
    in tmp, PORTA
    eor tmp, mask
    out PORTA, tmp
reti

incDC:
    ldi tmp, 0xfc
    in cnt, OCR1AL

    cpse cnt, tmp
        add cnt, step

    out OCR1AL, cnt
reti

decDC:
    ldi tmp, 0x00
    in cnt, OCR1AL

    cpse cnt, tmp
        sub cnt, step

    out OCR1AL, cnt
reti
