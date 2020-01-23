;******************************************************************************************************************
;
;					Warning !!!!
;
;	This example has NOT been tested on a real CRT as I do not own one
;
;	It's possible it could cause damage to real hardware! USE AT YOUR OWN RISK!
;
;******************************************************************************************************************

Multimode equ 1
	nolist

BuildCPC equ 1	; Build for Amstrad CPC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef vasm
		include "..\SrcALL\VasmBuildCompat.asm"
	else
		read "..\SrcALL\WinApeBuildCompat.asm"
	endif
	read "..\SrcALL\CPU_Compatability.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	read "..\SrcALL\V1_Header.asm"
	read "..\SrcALL\V1_BitmapMemory_Header.asm"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

	Call DOINIT			;Get ready


	call ScreenINIT

	ld hl,&C000			;Clear screen
	ld de,&C000+1
	ld bc,&4000-1
	ld (hl),0
	ldir

	ld a,&0F			;Track Color 1
	ld iy,&C050			;Screen Ram pos
	call DoTrackLine	;Construct 4track lines 
	call DoTrackLine
    ld a,&F0			;Track Color 2
	call DoTrackLine
	call DoTrackLine

    ld a,&FF			;Tree color
	ld iy,&C1E0			;Screen Ram pos
	call DoTreeLine		;Tree Trunks
	call DoTreeLine
	call DoTreeLine
	call DoTreeLine

    ld iy,&C370			;Screen Ram pos
	call DoGrassLine	;Grass (noise)
	call DoGrassLine
	call DoGrassLine
	call DoGrassLine

	jp start

DoTreeLine:				;Tree Trunks
	ld (IY+0),a
	ld (IY+1),a
	ld (IY+2),a
	ld (IY+3),a
	ld (IY+4),a

	ld (IY+&1A),a
	ld (IY+&1B),a
	ld (IY+&1C),a
	ld (IY+&1D),a
	ld (IY+&1E),a

	ld (IY+&30),a
	ld (IY+&31),a
	ld (IY+&32),a
	ld (IY+&33),a
	ld (IY+&34),a
	ld de,&50			;Because we've set MR=0, each line is directly below the last
	add iy,de
	ret

DoGrassLine:			;Grass
	ld b,&50
DoGrassLineB:
	ld a,r				;Generate noise
	rrca
	rrca
	xor b
	and &0F				;Force to cyan
	ld (IY+0),a
	inc iy
	djnz DoGrassLineB
	ret

DoTrackLine:
	ld (IY+&10),a
	ld (IY+&40),a
	ld de,&50			;Because we've set MR=0, each line is directly below the last
	add iy,de
	ret

Start:
	ld b,200			;Delay so we can see the components that build up the screen
waitabit
	halt
	halt
	halt
	halt
	halt
	djnz waitabit

	;Set Syncwidth to 4 (stops black borders at sides when we seriously alter the hpos

    ld bc,&bc03 		;Horizontal and Vertical Sync Widths %VVVVHHHH 
	ld a,&F4			;(Vert 16 / Horiz 4)
    out (c),c
    inc b
    out (c),a

    di 
    ld hl,&c9fb 		;EI, RET
    ld (&38),hl
    im 1 
	
	; We need to sync very tightly to the screen refresh
	
	ld b,&f5 			; Read in Vsync State
VsyncWait2
 	in a,(c) 
    rra
    jr nc,VsyncWait2	;Wait for Vsync (top of screen)
	
	ei
	halt				;Wait for next interrupt
	di

MainLoop:
	ld b,&f5 			;Read in Vsync State
VsyncWait
 	in a,(c) 
    rra
    jr nc,VsyncWait		;Wait for Vsync (top of screen)

	ld bc,&bc07			;Vertical Sync position (VSYNC)
	out (c),c
	ld bc,&bdff			;Set VSCYNC=255 (Impossible...Disables Vsync)
	out (c),c


    ld b,48 			;Wait until start of screen
wait1  
	ds 60,0 			;60 NOPs
    djnz wait1


	

	ld bc,&bc04 		;VTOT - Vertical Total
	ld a,3				;4 lines per screen
	out (c),c
	inc b
	out (c),a

	ld bc,&bc09 		;MR - Maximum Raster Address
	ld a,0 				;1 line per character block
	out (c),c
	inc b
	out (c),a

	ld bc,&bc06 		;VDISP - Vertical Displayed
	ld a,25			 	;Screen Default height
	out (c),c
	inc b
	out (c),a
	
	Ld hl,CommandList	;Source Command list
	ld ix,69			;Command Count
	
NextLine:
	ld bc,&bc0C 		;[12] 	RamPos H (48) 
	out (c),c 			;[16]
	ld a,(hl) 			;[8]
	inc hl   			;[8]
	inc b     			;[4]
	out (c),a 			;[16]
	dec b	 			;[4]

	inc c	 			;[4]	 RamPos L (0)
	out (c),c			;[16]
	ld a,(hl) 			;[8]
	inc hl	 			;[8] 
	inc b     			;[4]
	out (c),a 			;[16]
	dec b 	 			;[4]

	ld c,&02 			;[8]  	Offset (46) 
	out (c),c			;[16]
	ld a,(hl) 			;[8]
	inc hl   			;[8]
	inc b     			;[4]
	out (c),a 			;[16]
				;[152 ticks Total]

	ifdef Multimode
		ld bc,&7F00+128+4+8+0 ;[12] - ScreenMode change
		ld a,(hl)		;[8]
		add c			;[4]
		inc hl			;[8]
		out (c),a		;[16] Change screen mode
		ds 187			;NOPs
	else
		inc hl			;[8]
		ds 197			;enable this for mode changes too	
	endif
	dec ix 				;[12]
	ld a,ixl 			;[8]
	or ixh 				;[8]
	jp nz,NextLine  	;[12]
				;[36 ticks tota]


	ld bc,&bc06 		;VDISP	Vertical Displayed
	ld a,0    
	out (c),c
	inc b
	out (c),a

	ld bc,&bc04 		;VTOT	Vertical Total
	ld a,5-1       
	out (c),c
	inc b
	out (c),a

	ld bc,&bc09 		; MR	Maximum Raster Address 
	Ld a,7      		; Reset Character size
	out (c),c
	inc b
	out (c),a

	ld bc,&bc07 		; VSYNC	Vertical Sync position
	ld a,1				;Force a vsync
	out (c),c
	inc b
	out (c),a
	
 	ei
	halt				;Wait for last interrupt
	di
    jp MainLoop
	
	;RamH,RamL,Hshift,ScreenMode
CommandList:
	db 48+1,184+1,46,1
	db 48+1,184,46,1
	db 48+1,184+1,46,1
	db 48+1,184,46,1
	db 48+1,184+1,46,1
	db 48+1,184,46,1
	db 48+1,184+1,46,1
	db 48+1,184,46,1
	db 48+1,184+1,46,1
	db 48+1,184,46,1
	db 48+1,184+1,46,1
	db 48+1,184,46,1

	db 48,240,46,1
	db 48,240,46,1
	db 48,240,46,1
	db 48,240,46,1
	db 48,240,46,1
	db 48,240,46,1
	db 48,240,46,1
	db 48,240,46,1
	db 48,240,46,1

	db 48+1,184,46,0
	db 48+1,184,46,0
	db 48+1,184,46,0
	db 48+1,184,46,0

	db 48,40,46,0
	db 48,40,45,1
	db 48,40,44,1
	db 48,40,43,1

	db 48,40,42,1
	db 48,40,41,1
	db 48,40,40,1
	db 48,40,41,1
	db 48,40,42,1
	db 48,40,43,1
	db 48,40,44,1
	db 48,40,45,1
	db 48,40,46,1
	db 48,40,46,1
	db 48,40,46,1
	db 48,40,46,1
	db 48,40,46,1
	db 48,40,46,1
	db 48,40,45,1
	db 48,40,44,1

	db 48,40,43,1
	db 48,40,43,1
	db 48,40,44,1
	db 48,40,44,1
	db 48,40,46,1
	db 48,40,47,1
	db 48,40,48,1
	db 48,40,49,1
	db 48,40,48,1
	db 48,40,47,1
	db 48,40,46,1
	db 48,40,46,1
	db 48,40,46,1
	db 48,40,45,1
	db 48,40,45,1
	db 48,40,46,1
	db 48,40,47,1
	db 48,40,46,1
	db 48,40,45,1
	db 48,40,45,1
	db 48,40,45,1
	db 48,40,45,1
	db 48,40,45,1
	db 48,40,46,1
	db 48,40,46,1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





BitmapFont:
	ifdef BMP_UppercaseOnlyFont
		incbin "..\ResALL\Font64.FNT"			;Font bitmap, this is common to all systems
	else
		incbin "..\ResALL\Font96.FNT"			;Font bitmap, this is common to all systems
	endif

PrintSpace:
	ld a,' '
	jp PrintChar
;;;;;;;;;;;;;;;;;;;;;;;;;;
;debugger
;;;;;;;;;;;;;;;;;;;;;;;;;
Monitor_Full equ 1				;*** FULL monitor takes more ram, but shows all registers
Monitor_Pause equ 1 				;*** Pause after showing debugging info

	;read "..\SrcAll\Multiplatform_Monitor.asm"		;*** Full monitor
	;read "..\SrcAll\Multiplatform_MonitorSimple.asm"	;*** PushRegister and Breakpoint support
	read "..\SrcAll\Multiplatform_ShowHex.asm"	
	read "..\SrcAll\Multiplatform_ShowDecimal.asm"	
	;read "..\SrcAll\Multiplatform_MonitorMemdump.asm"

	read "..\SrcAll\MultiPlatform_Stringreader.asm"		;*** read a line in from the keyboard
	read "..\SrcAll\Multiplatform_StringFunctions.asm"	;*** convert Lower>upper and decode hex ascii

UseHardwareKeyMap equ 1

	align2
KeyboardScanner_KeyPresses: ds 16,255 	;Buffer for the keypresses

	read "..\SrcALL\Multiplatform_ScanKeys.asm"
	read "..\SrcALL\Multiplatform_KeyboardDriver.asm"

	;read "..\SrcCPC\CPCPLUS_V1_Palette.asm"
	read "..\SrcCPC\CPC_V1_Palette.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	read "..\SrcALL\V1_BitmapMemory.asm"
	read "..\SrcALL\Multiplatform_BitmapFonts.asm"

	read "..\SrcALL\V2_Functions.asm"
	read "..\SrcALL\V1_Footer.asm"
