.def tmp = r16

.cseg
    rjmp reset

.org $00C
    rjmp running

reset:
    ldi tmp, high(RAMEND)
    out SPH, tmp
    ldi tmp, low(RAMEND)
    out SPL, tmp

    ldi tmp, 0xff
    out DDRA, tmp

    ldi tmp, 0xff
    out PORTA, tmp

    ldi tmp, 0x00
    out TCCR1A, tmp

    ldi tmp, (1 << WGM12) | (1 << CS11) | (1 << CS10)
    out TCCR1B, tmp

    ; T = 2 * 220 ms = 0.44 - Moving LEDs takes only half a period
    ; f_oc1a = f_clk / (2 * N * (1 + ocr1a))
    ; (1 + ocr1a) = f_clk / (2 * N * f_oc1a)
    ; (1 + ocr1a) = f_clk / (2 * N * (1 / T))
    ; (1 + ocr1a) = 7372800 / (2 * 64 * (1 / 0.44)) - prescaler 64 is lowest available prescaler
    ; (1 + ocr1a) = 25344
    ; ocr1a = 25343
    ldi tmp, high(25343)
    out OCR1AH, tmp
    ldi tmp, low(25343)
    out OCR1AL, tmp

    ldi tmp, (1 << OCIE1A)
    out TIMSK, tmp

    sei

main:
rjmp main

running:
    in tmp, PORTA
    rol tmp
    out PORTA, tmp
reti
