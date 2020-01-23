	nolist

	org &400		;Start at &400 - we need a lot of memory for this!
	call CPCPLUS_INIT

	ld bc,&7fb8		;Page in PLUS registers	
	out (c),c		;(ASIC rambank at &4000-&7FFF)

	ld hl,DmaList	;Source data
	ld (&6C00),hl	;Set Channel 0 address

	ld a,1			;Playback speed
	ld (&6C02),a	;Set Channel 0 Playback speed (prescaler)
	
	ld a,%00000001	;Enable DMA channel 0
	ld (&6C0F),a	;Set Control register

	ld bc,&7fa0		;Page out PLUS registers
	out (c),c
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CPCPLUS_INIT:
	di
	ld b,&bc
	ld hl,PlusInitSequence	;Send the INIT sequence to the Gate Array
	ld e,17
PlusInitLoop:
	ld a,(hl)
	out (c),a
	inc hl
	dec e
	jr nz,PlusInitLoop	
	ei
	ret
PlusInitSequence:	;This is a special sequence to unock the CPC+ Asic... 
	db &ff,&00,&ff,&77,&b3,&51,&a8,&d4,&62,&39,&9c,&46,&2b,&15,&8a,&cd,&ee
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	align 2
;DmaList:
	;dw &073D	;SET ay reg 7 (mixer) to %00111101 (turn channel B on)
	;dw &090F	;SET ay reg 9 (channel B vol) to 15
	;dw &0301	;SET ay reg 3 (channel B pitch H) to 8
	;dw &4020	;STOP Command (end of sound)

DmaList:
	dw &2001	;REPEAT command (Start of loop - 2 loops - 3 plays in total)
;	incbin "\ResALL\Wave\hello16-3.pls"
	incbin "\ResALL\Wave\bestsamples16-3.pls"
	dw &4001	;LOOP command (Jump back to repeat)
	dw &4020	;STOP Command (end of sound)

