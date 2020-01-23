
SetCGBTileAttribs:			;PVH-RCCC	S=Sprites behind / V=Vert flip / H=Horiz flip / R=GBC Ext Ram patterns / C=Palette 
	push bc					
	push af
		ld a,b
		ld b,c
		ld c,a
		call LCDWait	;Wait for VDP Sync
		ld a,1		;Page in CGB ram
		ld (&FF4F),a

			ld	hl, $9800
			xor a
		
			rr b
			rra
			rr b
			rra
			rr b
			rra
			or c
			ld c,a
			add hl,bc
	pop af
		call LCDWait	;Wait for VDP Sync
	ld (hl),a
	push af
		ld a,0				;Page out CGB ram
		ld (&FF4F),a
	pop af
	pop bc
	ret
GBC_Turbo:
	ld a,0
	ld (&FFFF),a
	
	ld a,%00110000
	ld (&FF00),a
	
	ld a,1
	ld (&FF4D),a
	stop
	ret
	
; LCDWait:
	; push    af
        ; di
; .waitagain
        ; ld      a,($FF41)  
        ; and     %00000010  
        ; jr      nz,.waitagain 
    ; pop     af	
	; ret

	
StopLCD:
        ld      a,($FF40)
        rlca                    ; Put the high bit of LCDC into the Carry flag
        ret     nc              ; Screen is off already. Exit.
.wait:							; Loop until we are in VBlank
        ld      a,($FF44)
        cp      145             ; Is display on scan line 145 yet?
        jr      nz,.wait        ; no, keep waiting
        ld      a,($FF40)	; Turn off the LCD
        res     7,a             ; Reset bit 7 of LCDC
        ld      ($FF40),a
        ret
		
		
		
SetVRAM::
	inc	b
	inc	c
	jr	.skip
.loop   call LCDWait
        ldi      (hl),a
        ei
.skip	dec	c
	jr	nz,.loop
	dec	b
	jr	nz,.loop
	ret
	

SetTileOffset: ;Tileoffset B,C = X,Y.... 1,1 is further right and down than 0,0
	ld a,b
	xor %00000111
	or  %11111000
	inc a
	ld (&FF42),a	;Xpos
	ld a,c
	xor %00000111
	or  %11111000
	inc a
	ld (&FF43),a	;Ypos
	ret

	ifdef GBSpriteCache
DMACopy:
	push af
		ld a,GbSpriteCache/256	;Top byte of source address
		ld (&FF46),a			;Start the DMA
		ld  a,&28				;Delay
DMACopyWait: 
		dec a       
		jr  nz,DMACopyWait		;Wait until delay done
	pop af
	reti					;Return and enable interrupts
DMACopyEnd:
	endif

SetHardwareSprite:	
;A=Hardware Sprite No. BC = X,Y , E = Source Data, H=Palette etc
;On the gameboy You need to set XY to 8,16 to get the top corner of the screen
	
	push af
		rlca							;4 bytes per sprite
		rlca		
		push hl
		push de
			push hl
			ifdef GBSpriteCache
				ld hl,GBSpriteCache		;Cache to be copied via DMA
			else
				ld hl,&FE00				;Direct Sprite ram (unreliable)
			endif	
				ld l,a					;L address for selected sprite
				ld a,c					;y
				ldi (hl),a
				ld a,b					;x
				ldi (hl),a
				ld a,e					;tile
				ldi (hl),a
			pop de
			ld a,d						;attribs
			ldi (hl),a
		pop de
		pop hl
	pop af
	ret
	
WaitForScreenRefresh:
	ld      a,($FF40)
	or %00000010
	ld      ($FF40),a
WaitForScreenRefreshB:
	; Loop until we are in VBlank
    ld      a,($FF44)
    cp      145             ; Is display on scan line 145 yet?
	jr      nz,WaitForScreenRefreshB        ; no, keep waiting
	ret