.equ delayCnt = 15

.def tmp = r16

.cseg
    rjmp reset

reset:
    ldi tmp, high(RAMEND)
    out SPH, tmp
    ldi tmp, low(RAMEND)
    out SPL, tmp

    ldi tmp, 0xff
    out DDRA, tmp
    out PORTA, tmp

    clc

main:
    rcall aktivnost
    rcall delay
rjmp main

aktivnost:
    in tmp, PORTA
    rol tmp
    out PORTA, tmp
ret

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
