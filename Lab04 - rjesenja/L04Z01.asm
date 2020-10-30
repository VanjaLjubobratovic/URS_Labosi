.def tmp = r16

.cseg
    rjmp reset

.org $002
    rjmp turnOn

.org $004
    rjmp turnOff

reset:
    ldi tmp, high(RAMEND)
    out SPH, tmp
    ldi tmp, low(RAMEND)
    out SPL, tmp

    ldi tmp, (1 << 0)
    out DDRA, tmp
    out PORTA, tmp

    ldi tmp, (1 << ISC01) | (1 << ISC11)
    out MCUCR, tmp

    ldi tmp, (1 << INT0) | (1 << INT1)
    out GICR, tmp

    sei

main:
rjmp main

turnOn:
    ldi tmp, 0x00
    out PORTA, tmp
reti

turnOff:
    ldi tmp, (1 << 0)
    out PORTA, tmp
reti
