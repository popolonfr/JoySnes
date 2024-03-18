; This routine looking for the JoySNES in joystick port 1
; It supports R800 modes


bdos:	equ	05h

	org	0100h
main:
	call	check_ID	; Return Z flag if the adapter is plugged
	ret	nz

	ld	de,found
	ld	c,09h
	jp	bdos

found:
	db	"JOYSNES Found",0ah,0dh,024h

check_ID:

	di

	ld	hl,snes_id
	ld	b,7

next_cr:
	ld	a,%10011100	;  4 LSB
	call	wr_psg15

	push	bc
	ld	b,6		; about 29.56 microseconds (Z80)
	call	delay
	pop	bc

	call	wr_psg14
	and	%00001111
	ld	c,a

	ld	a,%10011101	; 4 MSB
	call	wr_psg15

	push	bc
	ld	b,1		; about 11.73 microseconds (Z80)
	call	delay
	pop	bc

	call	wr_psg14
	and	%00001111
	rlca
	rlca
	rlca
	rlca
	or	c

	cp	(hl)
	jr	nz,id_fail

	inc	hl
	djnz	next_cr
id_fail:
	push	af
	ld	a,%10001111
	call	wr_psg15
	pop	af

	ei
	ret

snes_id:
	db	"JOYSNES"

wr_psg15:
	push	af
	ld	a,0fh
	out	(0a0h),a
	pop	af
	out	(0a1h),a
	ret

wr_psg14:
	ld	a,0eh
	out	(0a0h),a
	in	a,(0a2h)
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
