.def tmp = r16
.def delayCnt = r22

.cseg
    rjmp reset

.org $002
    rjmp incFreq

.org $004
    rjmp decFreq

reset:
    ldi tmp, high(RAMEND)
    out SPH, tmp
    ldi tmp, low(RAMEND)
    out SPL, tmp

    ldi tmp, 0xff
    out DDRA, tmp
    ldi tmp, 0xff
    out PORTA,tmp

    ldi delayCnt, 20

    ldi tmp, (1 << ISC01) | (1 << ISC11)
    out MCUCR, tmp

    ldi tmp, (1 << INT0) | (1 << INT1)
    out GICR, tmp

    sei

main:
    rcall runningLight
    rcall delay
rjmp main

runningLight:
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
    mov r19, delayCnt

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

incFreq:
    ldi tmp, 0x01
    cpse tmp, delayCnt
        dec delayCnt
reti

decFreq:
    ldi tmp, 0xff
    cpse tmp, delayCnt
        inc delayCnt
reti
