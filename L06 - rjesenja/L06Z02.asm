.def tmp = r16

.cseg
    rjmp reset

reset:
    ldi tmp, high(RAMEND)
    out SPH, tmp
    ldi tmp, low(RAMEND)
    out SPL, tmp

    ldi tmp, (1 << PD4) | (1 << PD5)
    out DDRD, tmp

    ; 10 bit Fast PWM
    ldi tmp, (1 << COM1B1) | (1 << COM1B0) | (1 << COM1A1) | (1 << COM1A0) | (1 << WGM11) | (1 << WGM10)
    out TCCR1A, tmp

    ldi tmp, (1 << WGM12) | (1 << CS11)
    out TCCR1B, tmp

    ; TOP = 1023
    ; DC1 = 90%
    ; CM1 = TOP * DC1
    ; CM1 = 921
    ldi tmp, high(921)
    out OCR1AH, tmp
    ldi tmp, low(921)
    out OCR1AL, tmp

    ; DC2 = 10%
    ; CM2 = TOP * DC2
    ; CM2 = 102
    ldi tmp, high(102)
    out OCR1BH, tmp
    ldi tmp, low(102)
    out OCR1BL, tmp

main:
rjmp main
