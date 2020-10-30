.equ LED = 0

.def tmp = r16
.def mask = r20
.def state = r21
.def delayCnt = r22
.def operation = r23

.cseg
    rjmp reset

.org $002
    rjmp stop

.org $004
    rjmp start

reset:
    ldi tmp, high(RAMEND)
    out SPH, tmp
    ldi tmp, low(RAMEND)
    out SPL, tmp

    ldi tmp, 0xff
    out DDRA, tmp
    ldi tmp, 0xff
    out PORTA, tmp

    ldi tmp, 0x0f
    out PORTB, tmp
    ldi tmp, 0x00
    out DDRB, tmp

    ldi mask, (1 << LED)
    ldi state, 0x00
    ldi delayCnt, 1
    ldi operation, 0x00

    ldi tmp, (1 << ISC01) | (1 << ISC11)
    out MCUCR, tmp

    ldi tmp, (1 << INT0) | (1 << INT1)
    out GICR, tmp

    sei

main:
    sbrc operation, 0
        rjmp main

    sbis PINB, 0
        rcall init1
    sbis PINB, 1
        rcall init2
    sbis PINB, 2
        rcall init3
    sbis PINB, 3
        rcall init4

    sbrc state, 0
        rcall aktivnost1
    sbrc state, 1
        rcall aktivnost2
    sbrc state, 2
        rcall aktivnost3
    sbrc state, 3
        rcall aktivnost4

    rcall delay
rjmp main

init1:
    ldi state, (1 << 0)

    in tmp, PORTA
    ori tmp, 0xfe
    out PORTA, tmp
ret

aktivnost1:
    in tmp, PORTA
    eor tmp, mask
    out PORTA, tmp

    ldi state, 0x00
ret

init2:
    ldi state, (1 << 1)

    in tmp, PORTA
    ori tmp, 0xfe
    out PORTA, tmp

    ldi delayCnt, 4
ret

aktivnost2:
    in tmp, PORTA
    eor tmp, mask
    out PORTA, tmp
ret

init3:
    ldi state, (1 << 2)

    ldi tmp, 0xff
    out PORTA, tmp

    clc

    ldi delayCnt, 15
ret

aktivnost3:
    in tmp, PORTA
    rol tmp
    out PORTA, tmp
ret

init4:
    ldi state, (1 << 3)

    ldi tmp, 0xff
    out PORTA, tmp

    ldi delayCnt, 9
ret

aktivnost4:
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

stop:
    ldi operation, (1 << 0)
reti

start:
    ldi operation, 0x00
reti
