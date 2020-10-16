.equ delayCnt = 6

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

    ldi pos1, 0x0f
    ldi pos2, 0xf0
    clt

main:
    rcall delay
    rcall aktivnost
rjmp main

choose_direction:
    in tmp, PORTA
    cpi tmp, 0x00
    brne check_next_direction
        set
        rjmp end_direction
    check_next_direction:
        cpi tmp, 0xff
        brne end_direction
            clt
    end_direction:
ret

choose_carry:
    brts set_carry
        clc
        rjmp end_carry
    set_carry:
        sec
    end_carry:
ret

aktivnost:
    rcall choose_direction

    rcall choose_carry
    rol pos1
    andi pos1, 0x0f

    rcall choose_carry
    ror pos2
    andi pos2, 0xf0

    mov tmp, pos1
    or tmp, pos2

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
