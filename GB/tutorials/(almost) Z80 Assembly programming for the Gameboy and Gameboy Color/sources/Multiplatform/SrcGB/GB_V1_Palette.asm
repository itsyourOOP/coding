SetPalette:
	ifdef BuildGBC		;This function is called with A=Color number, HL=Color Def in &-GRB format
	push hl
		add a			;2 bytes per color
		ld c,a
		
		ld a,l			;Gameboy has 5 bits, but we only have 4
		and %00001111 	;Blue
		rlca
		ld d,a
				
		ld a,l
		and %11110000 	;Red
		rrca
		rrca
		rrca			
		ld e,a

		ld a,h			;Green
		swap a			;GBZ80 command, equivalent of 4x rlca
		
		rla		
		rl d			;Two green bits needed with blue
		rla
		rl d
		
		or e
		ld e,a			;DE now contains our palette in GBC format
		
		
		
		;;      xBBBBBGG GGGRRRRR
		LD	HL,$FF68	; Palette select register
		LD	A,C			; Load A with the palette+color number
		or 128			; Enable AutoInc
		call LCDWait	;Wait for VDP Sync
		LDI	(HL),A		; Select the palette and INC HL (now pointing at Data register)
		LD	(HL),E		; Send the Low byte color info
		LD	(HL),D		; Send the High byte color info
		
	pop hl
	endif
	ret
	
	