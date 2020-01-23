; Learn Multi platform Z80 Assembly Programming... With Vampires!

;Please see my website at	www.chibiakumas.com/z80/
;for the 'textbook', useful resources and video tutorials

;File		SMS Basic Functions
;Version	V1.0b
;Date		2018/7/28
;Content	Provides basic text functions using Firware calls

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PrintChar:
	push hl
	push bc
	push de
	push ix
	push iy
	push af
		ex af,af' 
			ld a,(Cursor_Y)
			ld d,a
			ld a,(Cursor_X)
			ld e,a
		
			ld iy,&C000		;We need to write here to set Green/Red
			add iy,de
			ld ix,&A000		;We need to write to this area to set Blue
			add ix,de
		
			ScreenDrawAllColors	;Can't use stack after thsi point
		ex af,af'
	
		sub 32			;we have no chars <32
		ld b,0
		ld c,a
		or a		
		rl c
		rl b
		rl c
		rl b
		rl c
		rl b
		ld hl,BitmapFont
		add hl,bc
		ld b,8			;8 rows per letter
		ld de,&0020		;32 bytes per line
		
FontNextLine:	
		ld a,(hl)
		ld (iy+0),a		;Write byte to all channels
		ld (ix+0),a
		add ix,de		;Move to next line
		add iy,de
		inc hl
		djnz FontNextLine

		ScreenStopDrawing	;Set Memory up to Turn off drawing
		
		ld a,(Cursor_X)
		inc a
		cp 32				;See if we've reached end of line
		jr nz,PrintCharXok
		ld hl,Cursor_Y
		inc (hl)
		ld a,0
PrintCharXok:
		ld (Cursor_X),a
	pop af
	pop iy
	pop ix
	pop de
	pop bc
	pop hl
	ret
	
PrintString:
	ld a,(hl)			;Print a '255' terminated string 
	cp 255
	ret z
	inc hl
	call PrintChar
	jr PrintString

WaitChar:
	ret

ScreenINIT:	
CLS:
		xor a
		ld (Cursor_X),a
		ld (Cursor_Y),a
		ld bc,32*25			;Draw a full screen of spaces to clear screen

CLSagain:
		ld a,' '
		call PrintChar
		dec bc
		ld a,b
		or c
		jr nz,CLSagain
	;ret
		ld hl,&0000
Locate:
	push af
		ld a,h
		ld (Cursor_X),a
		ld a,l
		ld (Cursor_Y),a
	pop af
	ret

GetCursorPos:
	push af
		ld a,(Cursor_X)
		ld h,a
		ld a,(Cursor_Y)
		ld l,a
	pop af
	ret

NewLine:
	push af
		xor a
		ld (Cursor_X),a
		ld a,(Cursor_Y)
		inc a
		ld (Cursor_Y),a
	pop af
	ret

Shutdown:	
	jr Shutdown
DOINIT:
	ret



Cursor_Y: db 0
Cursor_X: db 0


	ifndef BitmapFont
BitmapFont:
	ifdef BMP_UppercaseOnlyFont
		incbin "\ResALL\Font64.FNT"			;Font bitmap, this is common to all systems
	else
		incbin "\ResALL\Font96.FNT"			;Font bitmap, this is common to all systems
	endif
	endif