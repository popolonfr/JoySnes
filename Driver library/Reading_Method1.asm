; Fast method to read a SNES controller. R800 modes are supported.
;
; The status of the directions and boutons are stored into DE register as below
;
;     bit7   bit6   bit5   bit4   bit3   bit2   bit1   bit0
; D =  UP    DOWN   LEFT   RIGHT   B      Y    SELECT  START
; E =  A      X      L       R     1      1      1       1
;
; Modifies: AF, BC, and DE

PSG_SP	equ	0A0h	; Selection register port
PSG_WP	equ	0A1h	; Port for writing a register
PSG_RP	equ	0A2h	; Port for reading a register

snes_pad:
	di

	ld	c,%00011101
	call	WR2Reg15	; Function to read Up, Down, Left & Right at joystick port A

	ld	b,6
	call	delay		; Wait about 31.84 microseconds

	call	RD_Reg14	; Read Up, Down, Left & Right status
	rlca
	rlca
	rlca
	rlca
	ld	d,a		; Store Up, Down, Left & Right status to D register (MSB)

	ld	c,%00011111
	call	WR2Reg15	; Function to read B, Y, Select & Start at joystick port A

	ld	b,1		;
	call	delay		; Wait about 15.4 microseconds

	call	RD_Reg14	; Read B, Y, Select & Start status
	or	d
	ld	d,a		; Store B, Y, Select & Start status to D register (LSB)

	ld	c,%00011110
	call	WR2Reg15	; Function to read A, X, L & R at joystick port A

	ld	b,1		;
	call	delay		; Wait about 15.4 microseconds

	call	RD_Reg14	; Read A, X, L & R status
	rlca
	rlca
	rlca
	rlca
	ld	e,a		; Store A, X, L & R status to E register (MSB)

	ld	c,%00001111
	call	WR2Reg15	; Strob1 to 0
	ei
	ret
	
delay:
	ld	a,b
wt:	djnz	wt
	db	0EDh,055h	; Back if Z80 (RETN for Z80 and NOP for R800)
	ld	b,96
	cp	5		; Max counter value
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

RD_Reg14:
	ld	a,14
	out	(PSG_SP),a
	in	a,(PSG_RP)	; Read the second half of the character
	and	%00001111
	ret
