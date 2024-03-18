; This routine shows SNES boutons status with JoySNES in joystick port 1
; using the method "direct access". It supports R800 modes

PSG_SP	equ	0A0h	; Selection register port
PSG_WP	equ	0A1h	; Port for writing a register
PSG_RP	equ	0A2h	; Port for reading a register
bdos:	equ	0005h	; Function DOS call

	org	0100h
main:
	call	direct_a
	call	print_de
	jr	main

; direct access to SNES device ( in this example reading a Joypad)
;
; return the result in DE register
;
; DE = B:Y:SELECT:START:UP:DOWN:LEFT:RIGHT:A:X:L:R:[ID 4 bits]

direct_a:

	di

	ld	c,%10011110	; OUT0 in the high state (joystick port A)
	call	WR2Reg15

	ld	b,6		; about 29.56 microseconds
	call	delay

	ld	c,%10011100	; OUT0 in the low state
	call	WR2Reg15

	ld	b,16		; 16 bits

next_bit:
	ld	a,14
	out	(0a0h),a
	in	a,(0a2h)	; data stored in the DE register
	rra
	rl	e
	rl	d

	ld	c,%10011101	; CUP0 in the high state
	call	WR2Reg15

	push	bc
	ld	b,1		; about 11.73 microseconds
	call	delay
	pop	bc

	ld	c,%10011100	; CUP0 in the low state
	call	WR2Reg15

	push	bc
	ld	b,1		; about 11.73 microseconds
	call	delay
	pop	bc

	djnz	next_bit

	ld	c,%10001111
	call	WR2Reg15

	ei
	ret

delay:
	ld	a,b
wt:	djnz	wt
	db	0EDh,055h	; Back if Z80 (RETN for Z80 and NOP for R800)
	ld	b,96
	dec	a
	jr	nz,wt2
	ld	b,58
wt2:	djnz	wt2
	ret

WR2Reg15:
	ld	a,15
	out	(PSG_SP),a
	in	a,(PSG_RP)
	and	%10000000	; Keep bit 7 (Code LED)
	or	c
	out	(PSG_WP),a
	ret

; Display the DE register:
;
print_de:
	ld	hl,string_16
	ld	b,16

loop_prn16:
	xor	a
	rl	e
	rl	d
	adc	a,030h		; conversion to ASCII format
	ld	(hl),a
	inc	hl
	djnz	loop_prn16

	ld	de,string_16	; display
	ld	c,09h
	jp	bdos

string_16:
	ds	16
	db	0dh,"$"
