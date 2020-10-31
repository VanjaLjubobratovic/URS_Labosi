.def tmp = r16
.def del_x = r17
.def status = r19
.def pos1 = r20

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

	ldi tmp, 0x00
	out DDRB, tmp
	ldi tmp, 0x0f
	out PORTB, tmp

	ldi status, 0x00
	ldi del_x, 10
rjmp main

main:
	sbis PINB, 0
		rcall init0
	sbis PINB, 1
		rcall init1
	sbis PINB, 2
		rcall init2
	sbis PINB, 3
		rcall init3

	sbrc status, 0
		rcall act0
	sbrc status, 1
		rcall act1
	sbrc status, 2
		rcall act2
	sbrc status, 3
		rcall act3

	rcall delay
rjmp main

delay:
	push r21
	push r22
	push r23
	
	clr r21
	clr r22
	mov r23, del_x

	do:
		dec r21
		brne do
			dec r22
			brne do
				dec r23
				brne do
	pop r23
	pop r22
	pop r21
ret

reverse_binary:
	ldi r24, 0x80
	rev:
		rol tmp
		ror r24
		brcc rev
	mov tmp, r24
ret

//NAOPAKA STRELICA
init0:
	ldi status, (1 << 0)
	ldi tmp, 0xff
	out PORTA, tmp
	clt
ret

//kad je sve ugaseno, moramo palit ledice, postavimo T reg na 0 za orijentaciju u programu
//kad je sve upaljeno, moramo gasit ledice, postavimo T reg na 1
//za sve izme?u ostavljamo ga kako je bio
chose_dir:
	in tmp, PORTA
	cpi tmp, 0xff
	brne next_check
		clt
		rjmp end_check
	next_check:
		cpi tmp, 0x00
		brne end_check
			set
	end_check:
ret

act0:
	rcall chose_dir //da znamo gasimo li ili palimo
	in tmp, PORTA
	andi tmp, 0xf0 //koristit cemo samo pola tmp-a

	brts gasi
		lsl tmp //pomicemo tmp lijevo tako da dobivamo 0 na desnoj strani i palimo LED
		rjmp end_act0
	gasi:
		rol tmp //rotiramo lijevo tako da pomaknemo 1 koja je u sredini jedno mjesto lijevo
		ori tmp, 0x10 //"uguramo" novu 1 u sredinu
		andi tmp, 0xf0 //uzmemo samo pola tmp za svaki slucaj jer se tokom rotacije dogadjaju gluposti skroz desno na kraju
	end_act0:
	mov pos1, tmp //spremimo tmp u pos
	rcall reverse_binary //rotiramo tmp
	or tmp, pos1 //zalijepimo prethodni tmp na ovaj naopaki sad
	out PORTA, tmp
ret


//ROMB
init1:
	ldi status, (1 << 1)
	ldi tmp, 0xff
	out PORTA, tmp
	clt
ret

act1:
	rcall chose_dir //da znamo gasimo li ili palimo
	in tmp, PORTA
	andi tmp, 0xf0 //opet cemo samo uzet 1. dio tmp-a jer radimo sa reverse funkcijom

	brts gasi_romb
		lsl tmp
		rjmp end_act1
	gasi_romb: //Ovdje je cak i lakse, kad gasimo ledice samo postavimo carry na 1, zarotiramo desno da gurnemo tu 1 u tmp i gotovo
		sec
		ror tmp
	end_act1: //Apsolutno isto kao i ovaj prosli zadatak
		mov pos1, tmp
		rcall reverse_binary
		or tmp, pos1
		out PORTA, tmp
ret

//PUNA STRELICA DESNO
init2:
	ldi status, (1 << 2)
	ldi tmp, 0x0f
	out PORTA, tmp
	sec
	rcall delay
ret

chose_dir_strelica:
/*sluzi za isto i skoro je ista kao i prethodne funkcije za provjeru smjera, samo cemo malo drugacije
uvjete ispitivat sukladno strelici koju moramo crtat*/

	in tmp, PORTA
	cpi tmp, 0x0f //pocetak, moramo pomicat desno
	brne next_dir_strelica
		clt
		rjmp end_dir_strelica
	next_dir_strelica:
		cpi tmp, 0xf0 //sredina, moramo micat lijevo
		brne end_dir_strelica
			set
	end_dir_strelica:
ret

act2:
	rcall chose_dir_strelica
	in tmp, PORTA
	brtc desno //ako je T = 0, micemo sve desno, ako ne onda ulijevo
		sec //isto objasnjenje kao i ovaj sec nakon
		rol tmp
		rjmp end_act2
	desno:
		sec //moramo postavljat carry tako da pri rotaciji nebismo slucajno upalili LED na krajevima i dobili loading bar
		ror tmp
	end_act2:
	out PORTA, tmp
ret

/*kod za ovo u suprotnu stranu bi bio da promjenis pocetno stanje u init na 0xf0, 
da u chose_dir_strelica prvi cpi ide 0xf0, drugi 0x0f (dakle obrnes ih u biti)
i u act2 zamijenis rol i ror*
ONA PRAZNA STRELICA LIJEVO ILI DESNO JE IDENTICNA STVAR SAMO STO ZA POCETNI UVJET
NE STAVIS 0x0f ili 0xf0 NEGO 0x7f ili 0xfe dakle da je jedna 0 na krajevima i promjenis uvjete
u direction funkciji*/


//PRAZNA STRELICA NA GORE
init3:
	ldi status, (1 << 3)
	ldi tmp, 0xff
	out PORTA, tmp
ret

act3:
	in tmp, PORTA
	cpi tmp, 0xff
	breq pocetno_stanje
		andi tmp, 0xf0 //uzmemo samo jednu polovicu tmp-a jer cemo zrcalit
		lsl tmp
		ori tmp, 0x10 /*uzeli smo samo pola tmp-a znaci on izgleda npr. 1110 0000,
						kad ga pomaknemo lijevo dobijemo 1100 0000, buduci da ne zelimo punu strelicu, moramo ugurat jednu 1 u sredinu
						da dobijemo 1101 0000 tako da kad napravimo ovaj reverse na kraju, imamo 1101 1011*/
		rjmp end_act3
	pocetno_stanje: //sve LED su ugasene, trebamo stvorit 0 u sredini
		andi tmp, 0xf0
		lsl tmp
	end_act3:
	mov pos1, tmp
	rcall reverse_binary
	or tmp, pos1
	out PORTA, tmp 
ret