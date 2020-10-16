.equ delayCnt = 9

.def tmp = r16

.cseg
    rjmp reset

reset:
    ldi tmp, high(RAMEND)
    out SPH, tmp
    ldi tmp, low(RAMEND)
    out SPL, tmp

    ldi tmp, (1 << 3)
    out DDRA, tmp

main:
    sbi PORTA, 3
    rcall delay

    cbi PORTA, 3
    rcall delay
rjmp main

delay:
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
ret
