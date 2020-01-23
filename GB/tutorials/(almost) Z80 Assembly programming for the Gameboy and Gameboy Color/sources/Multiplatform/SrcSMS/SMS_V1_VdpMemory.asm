
clearVram:
    ; set VRAM write address to 0 by outputting &4000 ORed with &0000
	ld hl, &0000	
    ld bc, &4000	
    call prepareVram
    clearVramLoop:
        ld a,&00    ;	 Value to write
        out (vdpData),a ; Output to VRAM address, which is auto-incremented after each write
        dec bc
        ld a,b
        or c
        jp nz,clearVramLoop
    ret

prepareVram:
    push af
	    ld a,l
	    out (vdpControl),a
	    ld a,h
	    or &40					;we set bit 6 to define that we want to write data... as the VDP ram only goes from &0000-&3FFF this does not cause a problem
	    out (vdpControl),a
   pop af
    ret

setUpVdpRegisters:
    ld hl,VdpInitData
    ld b,VdpInitDataEnd-VdpInitData
    ld c,vdpControl
    otir
    ret

VdpInitData:
	db &06 ; reg. 0, display and interrupt mode.
	db 128+0
	db &a1 ; reg. 1, display and interrupt mode.
	db 128+1
	db &ff ; reg. 2, name table address. &ff = name table at 		&3800
	db 128+2
	db &ff ; reg. 3, Name Table Base Address  (no function)			&0000
	db 128+3
	db &ff ; reg. 4, Color Table Base Address (no function)			&0000
	db 128+4
	db &ff ; reg. 5, sprite attribute table. -DCBA98- = bits of address	$3f00
	db 128+5
	db &00;&ff ; reg. 6, sprite tile address.    -----D-- = bit 13 of address	$2000
	
	db 128+6
	db &00 ; reg. 7, border color.		 ----CCCC = Color
	db 128+7
	db &00 ; reg. 8, horizontal scroll value = 0.
	db 128+8
	db &00 ; reg. 9, vertical scroll value = 0.
	db 128+9
	db &ff ; reg. 10, raster line interrupt. Turn off line int. requests.
	db 128+10
VdpInitDataEnd:


	
	
	
writeToVramx4:			;This is used for the 2 color bitmaps of the Font
    ld a,(hl)
    out (vdpData),a		;1		Bitplanes
    out (vdpData),a		;2
    out (vdpData),a		;4
    out (vdpData),a		;8
    inc hl
    dec bc
    ld a,c
    or b
    jp nz, writeToVramx4
    ret
	
SetTileOffset: ;Tileoffset B,C = X,Y.... 1,1 is further right and down than 0,0
		ld a,b
		out (vdpControl),a
		ld a,&08+128
		out (vdpControl),a
		ld a,c
		xor %11011111
		out (vdpControl),a
		ld a,&09+128
		out (vdpControl),a
		
	ret
	
SetHardwareSprite:	;A=Hardware Sprite No. B,C = X,Y , D,E = Source Data, H=Palette etc
	push hl
	push de
	push af	
			push af
				ld h,&3F			;first byte is at &3F00
				ld l,a				;1 byte per tile - so load L with sprite number
				call prepareVram	;Get the memory address so we can write to it
				ld a,c				;Y pos
				out (vdpData),a
			pop af
			
			rlca					;2 bytes per tile - 1'st is X, 2nd is tile number
			ld h,&3F
			add &80					;next data Starts from &3F80
			ld l,a
			call prepareVram		;Get the memory address so we can write to it
			
			ld a,b					;X Pos
			out (vdpData),a
			ld a,e					;tile number
			out (vdpData),a
	pop af
	pop de
	pop hl
WaitForScreenRefresh:
	ret
	
