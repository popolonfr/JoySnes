; Routine to read the JoySNES ID and the version. R800 modes are supported.
;
; Output: rd_id is pointer to JoySNES ID
;         rd_ver is pointer to the version number
;
; Modifies: AF, BC, E and HL
;
; Works in extended mode only

PSG_SP	equ	0A0h	; Selection Port of a register 
PSG_WP	equ	0A1h	; Writing Port to a register
PSG_RP	equ	0A2h	; Reading Port to a register

bdos:	equ	0005h

snes_ver:
	di
	ld	hl,rd_id	; HL = Aera to store ID and version number
	ld	b,12		; 7 characters + space + 4 of version (counter)

next_cr:
	ld	c,%00011100
	call	WR2Reg15	; get the first 4 bits (joystick port A)

	ld	c,b
	call	delay		; Wait about 31.85 or 15.4 microseconds
	ld	b,c
	
	call	RD_Reg14	; Read the first half of the character
	ld	e,a

	ld	c,%00011101
	call	WR2Reg15	; get the second 4 bits

	ld	c,b
	call	delay2		; Wait about 15.4 microseconds
	ld	b,c
	
	call	RD_Reg14	; Read the second half of the character
	rlca
	rlca
	rlca
	rlca
	or	e

	ld	(hl),a
	inc	hl
	djnz	next_cr

id_fail:
	ld	c,%00001111
	call	WR2Reg15	; mode 1
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
	cp	12
	jr	z,wt11		; Jump if step1

delay2:
	db	0EDh,055h	; Back if Z80 (RETN for Z80 and NOP for R800)
	ld	b,58
wt:	djnz	wt	
	ret

wt11:
	ld	b,5
wt11a:	djnz	wt11a

	db	0EDh,055h	; Back if Z80 (RETN for Z80 and NOP for R800)
	ld	b,98
wt11b:	djnz	wt11b	
	ret
jsnes_id:
	db	"JOYSNES"
rd_id:
	ds	8
rd_ver:
	ds	4