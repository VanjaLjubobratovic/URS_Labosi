.equ LED = 0
.equ BTN = 0

.equ delayCnt = 4

.def tmp=r16
.def mask = r20

.cseg
    rjmp reset

reset:
    ldi tmp, high(RAMEND)
    out SPH, tmp
    ldi tmp, low(RAMEND)
    out SPL, tmp

    ldi tmp, (1 << LED)
    out DDRA, tmp
    ldi tmp, (1 << LED)
    out PORTA,tmp

    ldi tmp, (1 << BTN)
    out PORTB,tmp
    ldi tmp, 0x00
    out DDRB,tmp

    ldi mask, (1 << LED)

main:
    sbis PINB, BTN
        rcall aktivnost1

    rcall delay
rjmp main

aktivnost1:
    in tmp, PORTA
    eor tmp, mask
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
