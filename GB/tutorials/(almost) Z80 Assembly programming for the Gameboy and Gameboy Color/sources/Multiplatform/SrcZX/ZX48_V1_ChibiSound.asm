;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		Speccy beeper test
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ChibiSound_SetZX:; a=BSSSSSSS B=border effect, S=speed
				 ;Special function to set tone lenth, and turn off the border effect

	push bc
		ld b,a
		bit 7,a
		ld a,%00010000
		jr z,ChibiSound_SetZXborder
		ld a,%00010001
ChibiSound_SetZXborder:	
		ld (ZX_SoundBorderFX_Plus1-1),a
		
		ld a,%11111111
		rr b
		rr a
		rr b
		rr a
		ld (ZX_SoundFX2_Plus1-1),a	;Outer delay
		ld a,b
		and %00111111
		ld (ZX_SoundFX1_Plus1-1),a	;Inner Frequency
	pop bc
	ret

ChibiSound: ;NVTTTTTT
	or a	;0=mute
	ret z
	push af
		;No distortion
		ld hl,&113E;ld a,%00010001 - Selfmod
		
		bit 7,a
		jr z,ApplyNoise
		
		;Use R as a source of distortion
		ld hl,&5FED;ld a,r - Selfmod
		
ApplyNoise:
		ld (NoiseEffect_Plus2-2),hl
	pop af
	
	and %00111111
	ld h,a	;HL is Pitch
	ld l,0
	
	or a	;Clear Carry Flag
	rr h
	rr l
	rr h
	rr l
	rr h
	rr l
	rr h
	rr l
	
	ld a,h	;DE is no of repeats
	cpl
	and %00000011 ;<--SM ***
ZX_SoundFX1_Plus1;%00000011		;Frequency
	ld d,a
	ld a,l
	cpl
	and %11111111 ;<--SM ***	;Delay
ZX_SoundFX2_Plus1:
	ld e,a
	
	or a	;Clear Carry Flag
	rr d
	rr e
	or a	;Clear Carry Flag
	rr d
	rr e
	or a	;Clear Carry Flag
	rr d
	rr e
	
	inc d
	inc e 
	inc h
	inc l
	ld (ZXTone_Plus2-2),hl	;Set pitch
loopy:
	ld a,%00010001;ld a,r <-- SM ***
NoiseEffect_Plus2:
	xor h			 ;Flip the bits using H
	and %00010001	 ;<--SM ***
ZX_SoundBorderFX_Plus1:		;bit5 = sound , bit 0= blue flashing border
	ld h,a
	out (&fe),a				;<---- BEEP@
	ld bc,&0	;<--SM ***
ZXTone_Plus2:
pausey:
	dec c
	jr nz,pausey	;Loop between beeps
	dec b
	jr nz,pausey	
	dec e
	jr nz,loopy		;Time to keep beeping
	dec d
	jr nz,loopy
	ret