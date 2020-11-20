.def tmp = r16
.def mask = r17
.def direction = r18
.def ocval = r19

.cseg
    rjmp reset

.org $00C
    rjmp timer1

.org $010
    rjmp timer1

.org $026
    rjmp timer0

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
    ldi direction, 0x00
    ldi ocval, 0x00

    ldi tmp, (1 << WGM01) | (1 << CS01) | (1 << CS00)
    out TCCR0, tmp

    ldi tmp, 224
    out OCR0, tmp

    ldi tmp, (1 << WGM10)
    out TCCR1A, tmp

    ldi tmp, (1 << WGM12) | (1 << CS11) | (1 << CS10)
    out TCCR1B, tmp

    ldi tmp, high(250)
    out OCR1AH, tmp
    ldi tmp, low(250)
    out OCR1AL, tmp

    ldi tmp, (1 << OCIE1A) | (1 << TOIE1) | (1 << OCIE0)
    out TIMSK, tmp

    sei

main:
rjmp main

timer1:
    in tmp, PORTA
    eor tmp, mask
    out PORTA, tmp
reti

timer0:
    sbrc direction, 0
        rjmp falling

rising:
    inc ocval
    cpi ocval, 0xfe
        brne end

    sbr direction, 1
    rjmp end

falling:
    dec ocval
    cpi ocval, 0x01
        brne end

    cbr direction, 1

end:
    out OCR1AL, ocval
reti
