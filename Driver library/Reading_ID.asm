; Routine to read the JoySNES ID. R800 modes are supported.
;
; Output: Set Z flag when the JoySNES adapter is plugged
;
; Modifies: AF, BC, E and HL
;
; Works in extended mode only

PSG_SP	equ	0A0h	; Selection register port
PSG_WP	equ	0A1h	; Port for writing a register
PSG_RP	equ	0A2h	; Port for reading a register

snes_ver:
	di
	ld	hl,jsnes_id	; HL = Area to store ID and version number
	ld	b,7		; 7 characters (counter)

next_cr:
	ld	c,%00011100
	call	WR2Reg15	; Get the first 4 bits (joystick port A)

	ld	c,b
	call	delay		; Wait about 31.85 or 15.4 microseconds
	ld	b,c
	
	call	RD_Reg14	; Read the first half of the character
	ld	e,a

	ld	c,%00011101
	call	WR2Reg15	; Get the second 4 bits

	ld	c,b
	call	delay2		; Wait about 15.4 microseconds
	ld	b,c
	
	call	RD_Reg14	; Read the second half of the character
	rlca
	rlca
	rlca
	rlca
	or	e

	cp	(hl)
	jr	nz,id_fail

	inc	hl
	djnz	next_cr

id_fail:
	push	af
	ld	c,%00001111
	call	WR2Reg15	; mode 1
	pop	af
	ei
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

delay:
	ld	a,b
	cp	7
	jr	z,wt7		; Jump if first delay

delay2:
	db	0EDh,055h	; Back if Z80 (RETN for Z80 and NOP for R800)
	ld	b,58
wt:	djnz	wt	
	ret

wt7:
	ld	b,5
wt7a:	djnz	wt7a

	db	0EDh,055h	; Back if Z80 (RETN for Z80 and NOP for R800)
	ld	b,98
wt7b:	djnz	wt7b	
	ret

jsnes_id:
	db	"JOYSNES",32
