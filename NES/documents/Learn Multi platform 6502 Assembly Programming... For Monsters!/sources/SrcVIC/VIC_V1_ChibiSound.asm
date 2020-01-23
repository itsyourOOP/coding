ChibSoundMute:
	lda $900E
	and #%11110000
	sta $900E		;bit 0-3 sets volume of all sound
	rts
ChibiSound:
	cmp #0
	beq ChibSoundMute
	pha
		and #%10000000
		bne ChibiSoundNoise
	pla
	pha
		and #%00111111
		eor #%00111111
		clc
		rol
		ora #%10000000
		
		sta $900B	;Frequency for oscillator 2 (medium) (on: 128-255)
		lda #0
		sta $900D	;Frequency of noise source
	
ChibiSoundNoiseDone:	
	pla
	and #%01000000
	clc
	ror
	ror
	ror
	ora #%00000111
	sta z_as
	lda $900E
	and #%11110000
	ora z_as
	sta $900E		;bit 0-3 sets volume of all sound
	rts
ChibiSoundNoise:	
	pla
	pha
		and #%00111111
		eor #%00111111
		clc
		rol
		;rol
		ora #%10000000
		sta $900D	;Frequency of noise source
		lda #0
		sta $900B	;Frequency for oscillator 2 (medium) (on: 128-255)
	jmp ChibiSoundNoiseDone