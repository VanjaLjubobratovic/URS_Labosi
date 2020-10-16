.equ delayCnt = 9

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

main:
    rcall aktivnost
    rcall delay
rjmp main

aktivnost:
    in tmp, PORTA
    cpi tmp, 0x00
    breq resetleds
        clc
        ror tmp
        rjmp end
    resetleds:
        ldi tmp, 0xff
    end:
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
