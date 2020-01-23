nolist

;Uncomment one of the lines below to select your compilation target

BuildCPC equ 1	; Build for Amstrad CPC
;BuildMSX equ 1 ; Build for MSX
;BuildTI8 equ 1 ; Build for TI-83+
;BuildZXS equ 1  ; Build for ZX Spectrum
;BuildENT equ 1 ; Build for Enterprise
;BuildSAM equ 1 ; Build for SamCoupe
 
;BuildMSX_MSX1 equ 1

;ScrColor16 equ 1		;Use 16 color mode on the ENT and CPC
;ScrWid256 equ 1		;Use 256 pixel wide mode on the ENT and CPC

;ScrTISmall equ 1		;Use narrow fonts on the TI

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef vasm
		include "..\SrcALL\VasmBuildCompat.asm"
	else
		read "..\SrcALL\WinApeBuildCompat.asm"
	endifcaca
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	read "..\SrcALL\V1_Header.asm"
	read "..\SrcALL\V1_BitmapMemory_Header.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

	Call DOINIT		;Get ready

;	call ScreenINIT		;Enable the Bitmap Screen
     di ; on commence par couper les interruptions


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ld hl,Palette
	ld b,17
PaletteAgain:
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	push hl

	ex de,hl
	push bc

	ld a,17
	sub b

	call SetPalette

	pop bc
	pop hl

	dec b
	jp nz,PaletteAgain
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ld hl,&c9fb 	;EI RET
    ld (&38),hl		;Empty Interrupt handler
    im 1			;Enable interrupt mode 1
	ei
	
	ld b,&f5 		;read in from 8255 PPI chip 
WaitForVsync2:
	in a,(c) 		;Get Vblank State
    rra				;Get Bit 0
    jr nc,WaitForVsync2	;Wait for Vsync
		
	halt			;Wait for Interrupt



NewFrame:
	ld b,&f5 		;read in from 8255 PPI chip 
WaitForVsync:
	in a,(c) 		;Get Vblank State
    rra				;Get Bit 0
    jr nc,WaitForVsync	;Wait for Vsync

	di			;[4]
	ds 32*64		;[2048] VBlank time

	ds 32*64		;[2048] First 32 lines 
	ld iyl,100		;[12]
	ds 32			;[128]

	;We're going to do 2 mode changes immediately after each other...
	;Screenmode can only change once a line, so if we're time it
	;EXACTLY at the end of a line we can do both in one go!
NewVLine:	
	ld bc,&7F00+128+4+8+0 	;[12] - ScreenMode change
	out (c),c		;[16] Change screen mode to 0
	inc c			;[4]
	out (c),c		;[16] Change screen mode to 1
	dec c			;[4]

	;You can do some work here, but it must be the equivalent of 110 NOPs
	ds 110			;[440]

	dec iyl			;[8]
	jp nz,NewVLine	;[12]
				;Total since NewLine...512 = 2 line
	jp NewFrame

Palette:
defw &0000;0  -GRB
defw &00F0;1  -GRB
defw &055F;2  -GRB
defw &0FFF;3  -GRB
defw &0888;4  -GRB
defw &00DD;5  -GRB
defw &0F0F;6  -GRB
defw &0B84;7  -GRB
defw &0F04;8  -GRB
defw &09EF;9  -GRB
defw &0090;10  -GRB
defw &0459;11  -GRB
defw &0FF0;12  -GRB
defw &000C;13  -GRB
defw &0AE0;14  -GRB
defw &0900;15  -GRB
defw &0000;0  -GRB


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	read "..\SrcALL\V1_BitmapMemory.asm"

	read "..\SrcAll\V1_Palette.asm"

	read "..\SrcALL\V1_Functions.asm"
	read "..\SrcALL\V1_Footer.asm"
