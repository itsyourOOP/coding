; The Enterprise uses a single byte for it's palette,
; it uses 3 bits for it's green, and red, and 2 bits for blue
; this is because the eye tends to be better at seeing green, and red than blue, but it means our greyscales may come out kind of yellow.




SetPalette:
	cp 8
	jr nc,SkipENTPalette	;Can only set first 8 palettes on ENT in 16color mode
							;The second 8 colors are the same as the first, with an 'offset' making them brighter, 
							;or tinting them
	push af

		ld a,l
		and &F0
		ld b,a	 ;R - we'll use 3 bits of this
		
		ld a,l
		and &0F  ;B - we'll use 2 bits of this
		rrca
		rrca
		rrca
		rrca
		ld l,a

		ld a,h	;G - we'll use 3 bits of this
		rrca
		rrca
		rrca
		rrca
		ld h,a
		xor a	;We need data in format: g0 | r0 | b0 | g1 | r1 | b1 | g2 | r2 | - x0 = lsb 

		rl b	;r2
		rra
		rl h	;g2
		rra
		rl l	;b1
		rra

		rl b	;r1
		rra
		rl h	;g1
		rra
		rl l	;b0
		rra

		rl b	;r0
		rra
		rl h	;g0
		rra
		
		ld c,a
	pop af
	ld hl,ENT_PALETTE-LPT+&FF00	
	;The color palette info needs to be saved into the LPT screen definition, ENT_PALETTE points to the color palette, and we need to offset by the current color number... remember we can only set the first 8 colors
	
	add l
	ld l,a		;We write the palette entry to the memory location in the LPT into the correct location
	ld (hl),c
SkipENTPalette:
	ret