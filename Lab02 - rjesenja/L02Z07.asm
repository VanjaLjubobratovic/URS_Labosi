.equ delayCnt = 12

.def tmp = r16
.def pos1 = r20
.def pos2 = r21

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

    ldi pos1, 0x00
    ldi pos2, 0x00

main:
    rcall delay
    rcall aktivnost
rjmp main

aktivnost:
    sec
    rol pos1
    sec
    ror pos2

    mov tmp, pos1
    eor tmp, pos2
    com tmp

    cpi tmp, 0xff
    brne end
        clr pos1
        clr pos2

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
