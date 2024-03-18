; Method to read a SNES controller by direct access. R800 modes are supported.
;
; The result is returned to the DE register as below
;
;     bit7   bit6   bit5   bit4   bit3   bit2   bit1   bit0
; D =  B      Y    SELECT  START   UP    DOWN   LEFT  RIGHT
; E =  A      X      L      R     [ 4 bits for Device ID  ]
;
; Modifies: AF and BC

PSG_SP	equ	0A0h	; Selection register port
PSG_WP	equ	0A1h	; Port for writing a register
PSG_RP	equ	0A2h	; Port for reading a register

snes_ctrl:
	di

	ld	c,%00011110
	call	WR2Reg15	; OUT0 in the high state (from controller port A)

	ld	b,6
	call	delay		; Wait about 31.84 microseconds

	ld	c,%00011100
	call	WR2Reg15	; OUT0 in the low state

	ld	b,16		; 16 bits to read (counter)
next_bit:
	ld	a,14
	out	(PSG_SP),a
	in	a,(PSG_RP)	; Data stored in the DE register
	rra
	rl	e
	rl	d		; Data stored in the DE register

	ld	c,%00011101
	call	WR2Reg15	; CUP0 in the high state

	push	bc		; Store counter loop
	ld	b,2
	call	delay		; Wait about 15.4 microseconds

	ld	c,%00011100
	call	WR2Reg15	; CUP0 in the low state

	ld	b,2
	call	delay		; Wait about 15.4 microseconds
	pop	bc		; Restore counter loop

	djnz	next_bit

	ld	c,%00001111
	call	WR2Reg15	; Strob1 to 0
	ei
	ret

delay:
	ld	a,b
wt:	djnz	wt
	db	0EDh,055h	; Back if Z80 (RETN for Z80 and NOP for R800)
	ld	b,98
	cp	6		; Max counter value
	jr	z,wt2
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
