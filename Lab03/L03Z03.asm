.def tmp = r16
.def state = r20
.def delayCnt = r21

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

    ldi tmp, 0x0f
    out PORTB, tmp
    ldi tmp, 0x00
    out DDRB, tmp

    ldi state, 0x00
    ldi delayCnt, 1

main:
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

    ldi tmp, 0xff
    out PORTA, tmp

    ldi delayCnt, 6
ret

aktivnost1:
    in tmp, PORTA

    ; Radimo sa pozitivnom logikom ('1' - upaljena ledica)
    com tmp

    ; Provjeravamo ako smo zadovoljili neki od rubnih uvjeta
    rcall choose_direction

    ; Odabiremo ispravan carry bit za rotaciju temeljem flag-a T
    brts a1_set_carry
        clc
        rjmp a1_end_carry
    a1_set_carry:
        sec
    a1_end_carry:

    ; Rotiramo i dodajemo odgovarajuci bit sa desne strane (na poziciju 0)
    rol tmp

    ; Uzimamo donji half byte
    andi tmp, 0x0f

    ; Preslikavamo donju polovicu na gornju
    rcall reverse_byte

    ; Vracamo u negativnu logiku
    com tmp

    out PORTA, tmp
ret

init2:
    ldi state, (1 << 1)

    ldi tmp, 0xff
    out PORTA, tmp

    ldi delayCnt, 12
ret

aktivnost2:
    in tmp, PORTA

    ; Radimo sa pozitivnom logikom ('1' - upaljena ledica)
    com tmp

    ; Provjeravamo ako smo zadovoljili neki od rubnih uvjeta
    rcall choose_direction

    ; Uzimamo donji half byte
    andi tmp, 0x0f

    ; Rotiramo u odgovarajucu stranu temeljem flag-a T
    brts a2_left_rot
        clc
        ror tmp
        rjmp a2_end_rot
    a2_left_rot:
        sec
        rol tmp
    a2_end_rot:

    ; Preslikavamo donju polovicu na gornju
    rcall reverse_byte

    ; Vracamo u negativnu logiku
    com tmp

    out PORTA, tmp
ret

init3:
    ldi state, (1 << 2)

    ldi tmp, 0xff
    out PORTA, tmp

    ldi delayCnt, 7
ret

aktivnost3:
    in tmp, PORTA

    ; Radimo sa pozitivnom logikom ('1' - upaljena ledica)
    com tmp

    ; Odabiremo ispravan carry bit za rotaciju temeljem vrijednosti tmp registra
    rcall choose_carry

    ; Rotiramo i dodajemo odgovarajuci bit sa desne strane (na poziciju 0)
    rol tmp

    ; Uzimamo donji half byte
    andi tmp, 0x0f

    ; Preslikavamo donju polovicu na gornju
    rcall reverse_byte

    ; Vracamo u negativnu logiku
    com tmp

    out PORTA, tmp
ret

init4:
    ldi state, (1 << 3)

    ldi tmp, 0xff
    out PORTA, tmp

    ldi delayCnt, 12
ret

aktivnost4:
    in tmp, PORTA

    ; Radimo sa pozitivnom logikom ('1' - upaljena ledica)
    com tmp

    ; Kopiramo donji dio byte-a da usporedimo sa 0x00
    mov r17, tmp
    andi r17, 0x0f

    ; Reversamo tmp u svakom slucaju
    rcall reverse_byte

    ; Ovisno o vrijednosti donjeg byte-a prethodnog stanja odabiremo rol ili samo reverse
    cpi r17, 0x00
    brne a4_skip_rol
        ; Odabiremo ispravan carry bit za rotaciju temeljem vrijednosti tmp registra
        rcall choose_carry
        rol tmp
        andi tmp, 0x0f
        rjmp a4_end_rol
    a4_skip_rol:
        andi tmp, 0xf0
    a4_end_rol:

    ; Vracamo u negativnu logiku
    com tmp

    out PORTA, tmp
ret

choose_direction:
    cpi tmp, 0x00
    brne check_next
        set
        rjmp end_check
    check_next:
        cpi tmp, 0xff
        brne end_check
            clt
    end_check:
ret

choose_carry:
    cpi tmp, 0x00
    brne zero_carry
        sec
        rjmp end_carry
    zero_carry:
        clc
    end_carry:
ret

reverse_byte:
    push r17
    push r18

    ldi r17, 0x80
    mov r18, tmp
    rotate_bit:
        rol r18
        ror r17
    brcc rotate_bit
    mov r18, r17
    or tmp, r18

    pop r18
    pop r17
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

