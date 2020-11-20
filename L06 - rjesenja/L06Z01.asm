.def tmp = r16

.cseg
    rjmp reset

reset:
    ldi tmp, high(RAMEND)
    out SPH, tmp
    ldi tmp, low(RAMEND)
    out SPL, tmp

    ldi tmp, (1 << PD4)
    out DDRD, tmp

    ; Fast PWM (OCR1A Top)
    ldi tmp, (1 << COM1B1) | (1 << COM1B0) | (1 << WGM11) | (1 << WGM10)
    out TCCR1A, tmp

    ldi tmp, (1 << WGM13) | (1 << WGM12) | (1 << CS11)
    out TCCR1B, tmp

    ; TOP = f_clk / (N * f_oc1b) - 1
    ; TOP = 46079 - for ~40Hz
    ; DC = 50%
    ; CM = TOP * DC
    ; CM = 23040 - for 50%
    ldi tmp, high(46079)
    out OCR1AH, tmp
    ldi tmp, low(46079)
    out OCR1AL, tmp

    ldi tmp, high(23040)
    out OCR1BH, tmp
    ldi tmp, low(23040)
    out OCR1BL, tmp

main:
rjmp main
