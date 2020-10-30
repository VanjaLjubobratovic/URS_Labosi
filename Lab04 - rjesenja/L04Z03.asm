.def tmp = r16
.def delayCnt = r22
.def counter = r23

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

    ldi tmp, 0xff
    out DDRA, tmp
    out PORTA, tmp

    ldi delayCnt, 4

    ldi tmp, (1 << ISC01) | (1 << ISC11)
    out MCUCR, tmp

    ldi tmp, (1 << INT0) | (1 << INT1)
    out GICR, tmp

    sei

main:
rjmp main

turnOn:
    in tmp, PORTA

    cpi tmp, 0x00
    brne skipBlink
        rcall blinkLeds
    skipBlink:

    lsl tmp
    out PORTA, tmp

    rcall delaySwitchDebounce
reti

turnOn:
    in tmp, PORTA

    cpi tmp, 0x00
    brne skipBlink
        rcall blinkLeds
    skipBlink:
        breq endTurnOn

        clc
        rol tmp

        out PORTA, tmp

    endTurnOn:
        rcall delaySwitchDebounce
reti

blinkLeds:
    ldi counter, 10
    ldi delayCnt, 9
    blink:
        in tmp, PORTA
        com tmp
        out PORTA, tmp

        rcall delay

        dec counter
        brne blink

    ldi delayCnt, 4
ret

turnOff:
    in tmp, PORTA
    sec
    ror tmp
    out PORTA, tmp

    rcall delaySwitchDebounce
reti

delaySwitchDebounce:
    rcall delay

    ldi tmp, (1 << INTF0) | (1 << INTF1)
    out GIFR, tmp
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
