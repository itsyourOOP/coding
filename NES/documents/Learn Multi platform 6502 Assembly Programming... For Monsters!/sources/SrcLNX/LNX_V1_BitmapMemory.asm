	;Y= $50 bytes per Yline = 00000000 01010000
	;Move Y into top byte 	= YYYYYYYY 00000000
	;Shift Right Twice      = 00YYYYYY YY000000
	;Shift Right Twice      = 0000YYYY YYYY0000
	
GetScreenPos:
	lda #$00		;Reset z_C
	sta z_c
	clc		

	tya 			;Move Y into top byte 	= YYYYYYYY 00000000
	ror 			
	ror z_c
	ror 
	ror z_c			;Shift Right Twice      = 00YYYYYY YY000000
	
	sta z_d			;Store High byte in total	
	lda z_c			
	sta z_e			;Store Low byte in total
	
	lda z_d			;Shift Right Twice      = 0000YYYY YYYY0000
	ror 
	ror z_c
	ror 
	ror z_c
	
	clc				;Add High byte to total
	adc z_d
	adc #$C0		;Screen base at &C0000
	sta z_d

	clc
	lda z_c			;Add Low byte to total
	adc z_e
	sta z_e
	
	lda z_d			;Add any carry to the high byte
	adc #0
	sta z_d
	
	clc				;Add the X pos 
	txa 
	adc z_e 
	sta z_e
	
	lda z_d			;Add any carry to the high byte
	adc #0
	sta z_d
	rts
	
GetNextLine:
	pushpair z_bc
		lda #$00
		sta z_b
		lda #$50	;Add 80 to move down a line
		sta z_c
		jsr AddDE_BC
	pullpair z_bc
	rts
	
	
ScreenInit:		;SUZY chip needs low byte setting first 
				;OR IT WILL WIPE THE HIGH BYTE!
	
	;Set screen ram pointer to $C000
	lda #$00
	sta $FD94	;DISPADR	Display Address L
	sta $FC08	;VIDBAS		Base address of video build buffer L (Sprites)
	
	lda #$C0	
	sta $FD95	;DISPADR	Display Address H
	sta $FC09	;VIDBAS		Base address of video build buffer H (Sprites)
	
	;Offset
	LDA #8
	STA $FC04	;HOFF		Offset to H edge of screen
	STA $FC06	;VOFF		Offset to V edge of screen

	;Defaults for Sprite sys
	lda #%01000010	
	sta $fc92	;SPRSYS		System Cotrlol Bits (RW)
	
	;Set to '$F3' after at least 100ms after power up for sprites
	lda #$f3								
	sta $FC83	;SPRINT		Sprite Initialization Bits (W)(U)
	
	;let susy take bus (For sprites)
	lda #1		
	sta $FC90	;SUZYBUSEN	Suzy bus enable FF

	;Do the palette
	lda #%00000000	;Palette Color 0 ----GGGG
	sta $FDA0
	lda #%01110000	;Palette Color 0 BBBBRRRR
	sta $FDB0
	
	lda #%00001111	;Palette Color 15 ----GGGG
	sta $FDAF
	lda #%00001111	;Palette Color 15 BBBBRRRR
	sta $FDBF
	rts
	
	
	
	