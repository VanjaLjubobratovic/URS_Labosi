.def tmp = r16
.def mask = r17

.cseg
    rjmp reset

.org $00C
    rjmp blink

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

    ldi tmp, 0x00
    out TCCR1A, tmp

    ldi tmp, (1 << WGM12) | (1 << CS11) | (1 << CS10)
    out TCCR1B, tmp

    ; f_oc1a = f_clk / (2 * N * (1 + ocr1a))
    ; (1 + ocr1a) = f_clk / (2 * N * f_oc1a)
    ; (1 + ocr1a) = 7372800 / (2 * 64 * 5) - prescaler 64 is lowest available prescaler
    ; (1 + ocr1a) = 11520
    ; ocr1a = 11519
    ldi tmp, high(11519)
    out OCR1AH, tmp
    ldi tmp, low(11519)
    out OCR1AL, tmp

    ldi tmp, (1 << OCIE1A)
    out TIMSK, tmp

    sei

main:
rjmp main

blink:
    in tmp, PORTA
    eor tmp, mask
    out PORTA, tmp
reti
