Plus_CopySpriteCompressed:	
	;Plus only uses 4 bits ----aaaa ----bbbb
	;this doubles up those nibbles into a single byte, eg aaaabbbb
	; a Sprite Num	, hl = End of the Source memory Loc (we work backward)

	ld e,&00	;Destination in plus bank
	add &41		;Sprites start at &4000 - we're working backwards (Stack abuse)
	ld d,a		; so start at &4100 for sprite 0

	; We do the plus sprite in 4 parts to not annoy the interrupts
	call Plus_CopySpriteCompressedPlusPart	
	dec d
	ld e,&C0	;&40C0
	call Plus_CopySpriteCompressedPlusPart	
	ld e,&80	;&4080
	call Plus_CopySpriteCompressedPlusPart	
	ld e,&40	;&4040

Plus_CopySpriteCompressedPlusPart: 
	;DE = Destination
	;HL = source
	push de
		ld (Plus_CopySpriteCompressed_StackRestore_Plus2-2),sp
		ex de,hl
		ld bc,&7fb8	;turn Plus Asic on
		di
		out (c),c
		ld b,&10	;no of writes (2 bytes per write)
		ld sp,hl
		ex de,hl
Plus_CopySpriteCompressed_Loop:
		ld a,(hl)	;Read in byte
		ld e,a
		rrca
		rrca
		rrca
		rrca
		ld d,a
		push de		;Write 2 nibbles to asic
		dec hl
		ld a,(hl)	;Read in byte
		ld e,a
		rrca
		rrca
		rrca
		rrca
		ld d,a
		push de		;Write 2 nibbles to asic
		dec hl
		djnz Plus_CopySpriteCompressed_Loop
		ld bc,&7fa0 	;turn asic off
		out (c),c
		ei
		ld sp,&0000
Plus_CopySpriteCompressed_StackRestore_Plus2:
	pop de	
	ret






Plus_SetSprite:
	ld a,d
SetHardwareSprite:
	; bc = X (0-160) ,Y (0-199 (>220 is negative)
	; d Sprite Num
	; e = Scale ----XXYY (0=off, 9=Mode 1, 13=Mode 0, 14=2xMode 1)
	di
	push bc
		ld bc,&7fb8		;TurnPlus on
		out (c),c
	pop bc
	rlca				;8 bytes of settings per sprite
	rlca				;(only 5 used)
	rlca
	ld h,&60
	ld l,a
	push de
		ex de,hl
			ld h,0		; set X coordinate for sprite 0
			ld l,b
			add hl,hl
			add hl,hl
		ex de,hl
		ld (hl),e
		inc l
		ld (hl),d
		inc l
		ld a,c			; set Y coordinate for sprite 0
		ld d,0
		ld e,a
		cp 220
		jr C,Plus_SetSprite_DoY
		ld d,255		;Offscreen sprite
Plus_SetSprite_DoY
		ld (hl),e
		inc l
		ld (hl),d
		inc l
	pop de
	ld (hl),e			;Scale of sprite / sprite off
	push bc
		ld bc,&7fa0		;TurnPlus Off
		out (c),c
	pop bc
	ret
	

	