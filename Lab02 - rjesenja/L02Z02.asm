.equ delayCnt = 4

.def tmp = r16
.def mask = r17

.cseg
    rjmp reset

reset:
    ldi tmp, high(RAMEND)
    out SPH, tmp
    ldi tmp, low(RAMEND)
    out SPL, tmp

    ldi tmp, (1 << 3)
    out DDRA, tmp

    ldi mask, (1 << 3)

main:
    in tmp, PORTA
    eor tmp, mask
    out PORTA, tmp

    rcall delay
rjmp main

delay:
    push r17
    push r18
    push r19

    clr r17
    clr r18
    ldi r19, delayCnt

    delay_loop:
        dec r17
        brne delay_loop
            dec r18
            brne delay_loop
                dec r19
                brne delay_loop

    pop r19
    pop r18
    pop r17
ret
