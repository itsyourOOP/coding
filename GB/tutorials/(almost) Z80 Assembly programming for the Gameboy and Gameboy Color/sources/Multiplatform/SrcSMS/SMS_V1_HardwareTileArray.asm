
FillAreaWithTiles:
	;BC = X,Y)
	;HL = W,H)
	;DE = Start Tile
	ld a,h
	add b
	ld h,a
	
	ld a,l
	add c
	ld l,a
FillAreaWithTiles_Yagain:
	push bc
		push de
		push hl
			call GetVDPScreenPos			;Move to the correcr VDP location
		pop hl	
		pop de		
FillAreaWithTiles_Xagain:	;Tilemap takes two bytes, ---pcvhn nnnnnnnn
		ld a,e				;p=Priority (1=Sprites behind) C=color palette (0=back 1=sprite), V=Vert Flip, H=Horiz Flip, N=Tilenum (0-511)
		out (vdpData),a		; ---pcvhn 
		ld a,d				
		out (vdpData),a		;nnnnnnnn

		inc de
		inc b
		ld a,b
		cp h
		jr nz,FillAreaWithTiles_Xagain
	pop bc

	inc c
	ld a,c
	cp l
	jr nz,FillAreaWithTiles_Yagain

	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DefineTiles:	;DE=VDP address, HL=Source,BC=Bytecount
	ex de,hl
	call prepareVram
	ex de,hl
DefineTiles2:
	ld a,(hl)
	out (vdpData),a
	inc hl
	dec bc
	ld a,b
	or c
	jp nz,DefineTiles2
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetVDPScreenPos:	;Move to a memory address in VDP by BC cursor position.... B=Xpos, C=Ypos
	push bc
		ld hl,&3800		;Address of TileMap (32x28 - 2 bytes per cell = &700 bytes)
		ld a,b
		ifdef BuildSGG
			add 6		;Need add 6 on Xpos for GG to reposition screen
		endif
		ld b,c
		ld c,a
		ifdef BuildSGG
			ld a,b
			add 3			;Need add 3 on Ypos for GG to reposition screen
			ld b,a
		endif
		xor a
		rr b
		rra
		rr b
		rra
		rlc c
		or c
		ld c,a
		add hl,bc
		call prepareVram
	pop bc
	ret