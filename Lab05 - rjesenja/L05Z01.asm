.def tmp = r16

.cseg
    rjmp reset

reset:
    ldi tmp, high(RAMEND)
    out SPH, tmp
    ldi tmp, low(RAMEND)
    out SPL, tmp

    ldi tmp, (1 << PD5)
    out DDRD, tmp

    ldi tmp, (1 << COM1A0)
    out TCCR1A, tmp

    ldi tmp, (1 << WGM12) | (1 << CS11) | (1 << CS10)
    out TCCR1B, tmp

    ; f_oc1a = f_clk / (2 * N * (1 + ocr1a))
    ; (1 + ocr1a) = f_clk / (2 * N * f_oc1a)
    ; (1 + ocr1a) = 7372800 / (2 * 64 * 2) - prescaler 64 is lowest available prescaler
    ; (1 + ocr1a) = 28800
    ; ocr1a = 28799
    ldi tmp, high(28799)
    out OCR1AH, tmp
    ldi tmp, low(28799)
    out OCR1AL, tmp

main:
rjmp main
