
;Uncomment one of the lines below to select your compilation target

;BuildCPC equ 1	; Build for Amstrad CPC
;BuildMSX equ 1 ; Build for MSX
;BuildTI8 equ 1 ; Build for TI-83+
;BuildZXS equ 1 ; Build for ZX Spectrum
;BuildENT equ 1 ; Build for Enterprise
;BuildSAM equ 1 ; Build for SamCoupe
;BuildSMS equ 1 ; Build for Sega Mastersystem
;BuildSGG equ 1 ; Build for Sega GameGear
;BuildGMB equ 1 ; Build for GameBoy Regular
;BuildGBC equ 1 ; Build for GameBoyColor 
	ifdef BuildMSX_MSX1
BuildMSX_MSX1VDP equ 1
	endif
	ifdef BuildMSX
	ifndef BuildMSX_MSX1
BuildMSX_MSXVDP equ 1
	endif
	endif

V9K equ 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef vasm
		include "..\SrcALL\VasmBuildCompat.asm"
	else
		read "..\SrcALL\WinApeBuildCompat.asm"
	endif
	read "..\SrcALL\CPU_Compatability.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	


;read "..\SrcALL\V1_Header.asm"
	read "..\SrcALL\V1_Header.asm"
	read "..\SrcALL\V1_VdpMemory_Header.asm"
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	Call DOINIT	; Get ready
	;call SetGBPaletteLight
;	call SetGBPaletteDark

	;call GBC_Turbo
	call CLS	
Again:
	ld hl,&0000		;Screen position - 0,0 is top left, H=X,L=Y
LocateAgain:
	push hl
		call Locate	;Set cursor position
		
		ld hl,Message	
		call PrintString;Print Message
		
	pop hl
	inc h	;Move Right 2
	inc h
	inc l	;Move Down 1
	ld a,l
	cp 3	;We're going to do this 3 times
	jp nz,LocateAgain

	call NewLine	;Newline command

	;on the SGG/SMS and MSX1 ,we need to calculate the address to write our data to, and point the VDP write register at it!
	
	ifdef BuildSMS
	    ld de, 128*8*4				;8 lines of 4 bytes per tile
	endif 	
	ifdef BuildSGG
	    ld de, 128*8*4				;8 lines of 4 bytes per tile
	endif 
	ifdef BuildMSX_MSX1VDP
		ld de, 128*8				;8 lines of 1 bytes per tile
	endif	
	
	;The MSx2 and V9K are NOT tile based systems, but I have written an 'emulator' which works in the same way, 
	;as it's faster than treating the screen as a bitmap device
	
	ifdef BuildMSX_MSXVDP
		ld de, 128					;Tilenumber
	endif
	ifdef BuildCPC
		ld de, 128					;Tilenumber
	endif
	
	;We need to load the memory address 
	
	ifdef BuildGMB
		ld	de, 128*2*8+&8000 		; $8000 is the start of the memory bank address , 2 bytes per line, 8 lines per tile
	endif
	ifdef BuildGBC
		ld	de, 128*2*8+&8000 		; $8000 is the start of the memory bank address , 2 bytes per line, 8 lines per tile
	endif
	
	ld	hl, SpriteData
	ld	bc, SpriteDataEnd-SpriteData
	call DefineTiles
	
	;We need to fill an area with numeric tiles, then we'll set those tiles to our chibiko character
	
	
	ld bc,&0303		;Start Position in BC
	ld hl,&0606		;Width/Height of the area to fill with tiles in HL
					;We need to load DE with the first tile number we want to fill the area with
	ifdef BuildGBC
		ld de,128	;Gameboy Tile number
	endif
	ifdef BuildGMB
		ld de,128	;Gameboy Tile number
	endif
	ifdef BuildSMS
		ld de,128	;SMS has 512 tiles, so start at 256
	endif
	ifdef BuildSGG
		ld de,128	;Sega GameGear has 512 tiles, so start at 256
	endif
	ifdef BuildMSX_MSX1VDP
		ld de,128	;MSX1 VDP
	endif
	ifdef BuildMSX_MSXVDP
		ld de,128	;V9K/MSX2
	endif
	ifdef BuildCPC
		ld de,128	;V9K test code
	endif
	call FillAreaWithTiles		;Fill a grid area with consecutive tiles 

	ld hl,&1F00
	call Locate	;Set cursor position
	ld a,"A"
	call PrintChar
	
	ld hl,&001F
	call Locate	;Set cursor position
	ld a,"B"
	call PrintChar
	
	ld hl,&001F
	call Locate	;Set cursor position
	ld a,"B"
	call PrintChar
	
	ld hl,&001B
	call Locate	;Set cursor position
	ld a,"C"
	call PrintChar
	
	ld hl,&00FF
	call Locate	;Set cursor position
	ld a,"D"
	call PrintChar
	
	
	
	
	
	ld hl,Palette
	ld b,17
PaletteAgain:
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	push hl

	z_ex_dehl
	push bc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	ld a,17
	sub b
	
	call SetPalette
	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	pop bc
	pop hl

	dec b
	jp nz,PaletteAgain

	di
	halt
	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ScrollTest
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	
	
	ld a,4
Scrollagain:		

	push af
	;xor a
	ld b,a
	ld c,a
	;call SetTileOffset
	
	
	;xor %00000111
	;or  %11111000
	;ld (&FF42),a
	;ld (&FF43),a
	pop af
	
	
	
	
	push af
		ld bc,&F000
decagain:
		dec bc
		ld a,b
		or c
		jp nz,decagain
	pop af
	inc a
	and %00000111
	
	;jp Scrollagain
	jp Again
	
	di
	halt
LCDWait2:
	push    af
        di
.waitagain
        ld      a,($FF41)  
        and     %00000010  
        jr      z,.waitagain 
    pop     af	
	ret

Palette:
	;   -grb
	dw &0000	;0 - Background
	dw &0099	;1
	dw &0E0F	;2
	dw &0FFF	;3 - Last color in 4 color modes
	dw &000F	;4
	dw &004F	;5
	dw &008F	;6
	dw &00AF	;7
	dw &00FF	;8
	dw &04FF	;9
	dw &08FF	;10
	dw &0AFF	;11
	dw &0CCC	;12
	dw &0AAA	;13
	dw &0888	;14
	dw &0444	;15
	dw &0000	;Border


	;Sprite Data of our Chibiko character, this needs to be in the native format of the graphics system we're working with
SpriteData:
	ifdef BuildGBC
		incbin "Z:\ResALL\sprites\RawGB.RAW"  
	endif
	ifdef BuildGMB
		incbin "Z:\ResALL\sprites\RawGB.RAW" 
	endif
	ifdef BuildMSX_MSX1VDP
		incbin "Z:\ResALL\sprites\RawMSX1.RAW" 
	endif
	ifdef BuildMSX_MSXVDP
		incbin "Z:\ResALL\sprites\RawMSXVdp.RAW"
	endif
	ifdef BuildCPC;V9K only
		incbin "Z:\ResALL\sprites\RawMSXVdp.RAW"
	endif
	ifdef BuildSMS
		incbin "Z:\ResALL\Sprites\RawSMS.RAW"
	endif
	ifdef BuildSGG
		incbin "Z:\ResALL\Sprites\RawSMS.RAW"
	endif
SpriteDataEnd:

	;2 bit bitmap font, this is generic for all systems
BitmapFont:
	ifdef BMP_UppercaseOnlyFont
		incbin "..\ResALL\Font64.FNT"			;Font bitmap, this is common to all systems
	else
		incbin "..\ResALL\Font96.FNT"			;Font bitmap, this is common to all systems
	endif
Message: db 'Hello World xxx!',255


	read "..\SrcALL\V1_VdpMemory.asm"
	read "..\SrcALL\V1_HardwareTileArray.asm"
	read "..\SrcAll\V1_Palette.asm"	
MonitorRam equ &DF00
Monitor_TMP1 					equ MonitorRam; &C011
Monitor_NextMonitorPos_2Byte	equ MonitorRam+2;&C012;-13
Monitor_EI_Reenable_2byte 		equ MonitorRam+4;&C014;-5
Monitor_Special					equ MonitorRam+6;&C016

	
Monitor_Pause equ 1 				;*** Pause after showing debugging info
	read "..\SrcALL\Multiplatform_ShowHex.asm"
	read "..\SrcALL\Multiplatform_Monitor_RomVer.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	read "..\SrcALL\V2_Functions.asm"
	read "..\SrcALL\V1_Footer.asm"
