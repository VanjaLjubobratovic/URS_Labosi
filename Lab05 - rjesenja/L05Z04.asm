.def tmp=r16
.def cnt1=r17
.def cnt2=r18
.def cnt3=r19
.def secLed = r20
.def minLeds = r21

.cseg
    rjmp reset

.org $00C
    rjmp clock

reset:
    ldi tmp, high(RAMEND)
    out SPH, tmp
    ldi tmp, low(RAMEND)
    out SPL, tmp

    ldi tmp, 0xff
    out DDRA, tmp

    ldi tmp, 0xff
    out PORTA, tmp

    ldi cnt1, 0
    ldi cnt2, 0
    ldi cnt3, 0
    ldi secLed, 0x01
    ldi minLeds, 0x01

    ldi tmp, 0x00
    out TCCR1A, tmp

    ldi tmp, (1 << WGM12) | (1 << CS10)
    out TCCR1B, tmp

    ; T = 2 * 1 ms = 0.002
    ; f_oc1a = f_clk / (2 * N * (1 + ocr1a))
    ; (1 + ocr1a) = f_clk / (2 * N * f_oc1a)
    ; (1 + ocr1a) = f_clk / (2 * N * (1 / T))
    ; (1 + ocr1a) = 7372800 / (2 * 1 * (1 / 0.002))
    ; (1 + ocr1a) = 7372.8 --> 7373
    ; ocr1a = 7372
    ldi tmp, high(7372)
    out OCR1AH, tmp
    ldi tmp, low(7372)
    out OCR1AL, tmp

    ldi tmp, (1 << OCIE1A)
    out TIMSK, tmp

    sei

    ldi tmp, 0xff

main:
rjmp main

clock:
    inc cnt1
    cpi cnt1, 250
        brne kraj
        clr cnt1

        inc cnt2
        cpi cnt2, 2
            brne kraj
            clr cnt2

            in tmp, PORTA
            eor tmp, secLed

            inc cnt3
            cpi cnt3, 20
                brne next
                clr cnt3
                lsl minLeds
                eor tmp, minLeds

            next:
            cpi tmp, 0x80
                brne kraj

                ldi minLeds, 0x01
                ori tmp, 0xfe

    kraj:
    out PORTA, tmp
reti
