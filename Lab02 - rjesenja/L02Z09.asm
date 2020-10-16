.equ delayCnt = 12

.def tmp = r16
.def pos = r20

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

    ldi pos, 0x0f

    set

main:
    rcall delay
    rcall aktivnost
rjmp main

reverse_byte:
    ldi r17, 0x80
    rotate_bit:
        rol tmp
        ror r17
    brcc rotate_bit
    mov tmp, r17
ret

aktivnost:
    brtc skip_rol
        andi pos, 0x0f
        cpi pos, 0x0f
        brne set_carry
            clc
            rjmp end_carry
        set_carry:
            sec
        end_carry:
            rol pos
            mov tmp, pos
            ori tmp, 0xf0
        clt
        rjmp end_rol
    skip_rol:
        set

    end_rol:
        rcall reverse_byte

    out LED_PORT, tmp
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
