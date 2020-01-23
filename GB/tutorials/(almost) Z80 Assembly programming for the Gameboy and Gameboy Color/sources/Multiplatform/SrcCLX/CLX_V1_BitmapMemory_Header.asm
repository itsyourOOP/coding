	macro ScreenDrawAllColors
		exx					;Red/Blue Component
			ld a,07			;%00000111 - Write RGB
			ld bc,&FFFF		
			out (c),a
			ld a,&20		;%00100000 - Write RGB
			ld bc,&0080
			out (c),a
		exx
	endm
	
	macro ScreenDrawRedBlue
		exx					;Red/Blue Component
			ld a,03			;%00000011 - Write Bank 1+2
			ld bc,&FFFF
			out (c),a
			ld a,&28		;%00101000 - Write VRAM, Write RedBlue
			ld bc,&0080
			out (c),a
		exx
	endm
	
	macro ScreenDrawGreen
		exx					;Green Component
			ld a,05			;%00000101 - Write Bank 1+3
			ld bc,&FFFF
			out (c),a
			ld a,&24		;%00100100 - Write VRAM, Write Green
			ld bc,&0080
			out (c),a
		exx
	endm
	
	macro ScreenStopDrawing
		exx					;Turn off drawing
			ld a,0
			ld bc,&FFFF		;Reset Bank writing
			out (c),a
			ld bc,&0080		;Reset Paging
			out (c),a
		exx
	endm
	
	macro ScreenStartDrawing
	endm