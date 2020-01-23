;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FillAreaWithTiles:
	;BC = X,Y)
	;HL = W,H)
	;DE = Start Tile

	ld a,h
	add b
	ld (zIXH),a
	ld a,l
	add c
	ld (zIXL),a
FillAreaWithTiles_Yagain:
	push bc
		
		push bc
			ld a,c
			ld c,b
			ld b,a
			ld	hl, $9800		;Get the position of the line
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
		pop bc
		
FillAreaWithTiles_Xagain:
		ld a,e
		call LCDWait	;Wait for VDP Sync
		ldi (hl),a			;Write each line's bytes
		inc de
		inc b
		ld a,(zIXH)
		cp b
		jr nz,FillAreaWithTiles_Xagain
	pop bc
	inc c
	ld a,(zIXL)
	cp c
	jr nz,FillAreaWithTiles_Yagain
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetVDPScreenPos:;Move to a memory address with BC... B=Xpos, C=Ypos
	ld a,c		
	ld c,b
	ld b,a
	
	ld	hl, $9800		;The tilemap starts at &9800
	xor a

	rr b	;Each line is 32 tiles
	rra		;and each tile is 1 byte
	rr b
	rra
	rr b
	rra
	or c	;Add XPOS
	ld c,a
	add hl,bc
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
DefineTiles:	;Write BC bytes from HL to DE for tile definition
	
DefineTiles2:
	call LCDWait	;Wait for VDP Sync
	ldi a,(hl)	;LD a,(hl), inc HL
	ld (de),a			
	inc de
	dec bc
	ld a,b
	or c
	jp nz,DefineTiles2
	ret
	