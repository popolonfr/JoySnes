; This routine shows SNES boutons status with JoySNES in joystick port 1
; using the method "fast access". It supports R800 modes


PSG_SP	equ	0A0h	; Selection register port
PSG_WP	equ	0A1h	; Port for writing a register
PSG_RP	equ	0A2h	; Port for reading a register
bdos:	equ	0005h	; Function DOS call

	org	0100h
main:
	call	get_jpad
	call	print_de
	jr	main

;
; The status of the direction and boutons stored into DE
;
;     bit7  bit6   bit5   bit4	 bit3  bit2   bit1   bit0
; D =  Up   Down   Left   Right   B	Y    Select  Start
; E =  A     X	    L	   R	  _	_      _      _
;

get_jpad:
	di

	ld	c,%10011101	; reading : Up Down Left Right
	call	WR2Reg15

	ld	b,6		; about 29.56 microseconds
	call	delay

	call	RD_Reg14
	rlca
	rlca
	rlca
	rlca
	ld	d,a

	ld	c,%10011111	; reading : B Y Select Start
	call	WR2Reg15

	ld	b,1		; about 11.73 microseconds
	call	delay

	call	RD_Reg14
	or	d
	ld	d,a

	ld	c,%10011110	; reading : A X L R
	call	WR2Reg15

	ld	b,1		; about 11.73 microseconds
	call	delay

	call	RD_Reg14
	rlca
	rlca
	rlca
	rlca
	ld	e,a

	ld	c,%10001111
	call	WR2Reg15

	ei
	ret

delay:
	ld	a,b
wt:	djnz	wt
	db	0EDh,055h	; Back if Z80 (RETN for Z80 and NOP for R800)
	ld	b,90
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

RD_Reg14:
	ld	a,14
	out	(PSG_SP),a
	in	a,(PSG_RP)	; Read the second half of the character
	and	%00001111
	ret

; Display the DE register.
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
