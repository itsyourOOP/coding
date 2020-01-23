GBSpriteCache equ &D000				;Source address of sprite buffer
VblankInterruptHandler equ &FF80	;Destination for DMA commands

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
	ifndef BuildCPC
	ifdef BuildMSX_MSX1
BuildMSX_MSX1VDP equ 1
	endif
	ifdef BuildMSX
	ifndef BuildMSX_MSX1
BuildMSX_MSXVDP equ 1
	endif
	endif
	endif
;V9K equ 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef vasm
		include "..\SrcALL\VasmBuildCompat.asm"
	else
		read "..\SrcALL\WinApeBuildCompat.asm"
	endif
	read "..\SrcALL\CPU_Compatability.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	ifdef BuildCPC
	read "..\SrcALL\V1_BitmapMemory_Header.asm"
	endif

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
	ifdef BuildMSX_MSX1VDP
		ld de, 128*8				;8 lines of 1 bytes per tile
	endif	
	
	ifndef BuildCPC
		ld	hl, SpriteData
		ld	bc, SpriteDataEnd-SpriteData
		call DefineTiles
	endif
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
	ifndef BuildCPC
		call FillAreaWithTiles		;Fill a grid area with consecutive tiles 
	endif
	;164
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;Sprite test
	;FE00	FE9F	Sprite Attribute Table (OAM) (Can’t change during screen redraw)
	ifdef BuildMSX
		ifdef BuildMSX_MSX1VDP
			ld de, &3800				;8 lines of 1 bytes per tile
		endif	
		
		ld	hl, HWSpriteData
		ld	bc, HWSpriteDataEnd-HWSpriteData
		call DefineTiles						;Load in the tile pattern data into the sprite area
		
		

		ld a,0			;HardSpriteNum
		ld bc,&1080		;XY
		ld h,0			;Tilenumber
		ld l,15			;Color
		Call SetHardwareSprite
		
		ld a,1			;HardSpriteNum
		ld bc,&8880		;XY
		ld h,2			;Tilenumber
		ld l,14			;Color
		Call SetHardwareSprite					;We don't need this if we use Big sprites
		
		ld a,2			;HardSpriteNum
		ld bc,&8088		;XY
		ld h,1			;Tilenumber
		ld l,13			;Color
		Call SetHardwareSprite					;
		
		ld a,3			;HardSpriteNum
		ld bc,&8888		;XY
		ld h,3			;Tilenumber
		ld l,12			;Color
		Call SetHardwareSprite
		
		
	endif
	ifdef BuildMSX
; 			    ------BD		B=big 16x16 sprites     D= double size sprite
		 ld a, %01000010		;(show screen) - Huge Sprites!!!1
		 out (VdpOut_Control),a
		 ld a,128+1				;1	4/16K	BL	GINT	M1	M3	-	SI	MAG
		 out (VdpOut_Control),a
		 di
		halt
	endif
	
	ifdef BuildCPC
		call CPCPLUS_INIT		;Turn on Plus features
		
		ld hl,HWSpriteData+&7F	;End of the sprite area
		ld a,0
		call Plus_CopySpriteCompressed ;define Sprite BMP
		
		ld bc,&4040				;XY
		ld a,0					;SpriteNum
		;     ----XXYY
		ld e,0			;Scale 
		call SetHardwareSprite

		ld a,16+3				;CPC+ sprites use colors 17-31
		ld hl,&0F0F
		call SetPalette			;Define Color 3 of Plus colors
	endif
	
	ifndef BuildMSX
	ifndef BuildCPC	
		;call WaitForScreenRefresh
		
		
		ld bc,&1040	;xy
		ld e,164	;pattern
		ld h,0		;Tiledetails
		ld a,0		;Sprite
		Call SetHardwareSprite
		ld a,8
		add b
		ld b,a
		inc e
		ld a,1
		Call SetHardwareSprite
		ld a,8
		add c
		ld c,a
		inc e
		inc e	
		ld a,2
		Call SetHardwareSprite
		ld a,-8
		add b
		ld b,a
		dec e
		ld a,3
		Call SetHardwareSprite
	endif
	endif
	
	
	;ld a,%10000110	;Double height sprites
	;ld (&FF40),a
	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;ld a,%00000001		;Turn on Vblank Interrupt
	;ld (&FFFF),a
	
	;call WaitForScreenRefresh
	
	; ifdef BuildGBx
		; ld a,%00000001		;Turn on Vblank Interrupt
		; ld (&FFFF),a
		; ei
		; call WaitForScreenRefresh
	; endif
	
	
	
	
	; call Monitor_MemDump	;Dump a number of bytes from a location
	; db 12			;Bytes to dump - only do 24 bytes on a TI
	; dw &D000		;Location to dump
	; call Monitor_MemDump	;Dump a number of bytes from a location
	; db 12			;Bytes to dump - only do 24 bytes on a TI
	; dw &FE00		;Location to dump
	
	
	
	;call Monitor
InfLoop
	
	jp Infloop
	
	;di
	;halt
	
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
	
	ld a,4
Scrollagain:		

	push af
	ld b,a
	ld c,a
	;call SetTileOffset
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
	
	jp Scrollagain
	di
	halt
	

	;Sprite Data of our Chibiko character, this needs to be in the native format of the graphics system we're working with
SpriteData:
	ifdef BuildGBC
		incbin "\ResALL\sprites\RawGB.RAW"  
		incbin "\ResALL\sprites\SpriteGB.RAW"  
		
	endif
	ifdef BuildGMB
		incbin "\ResALL\sprites\RawGB.RAW" 
		incbin "\ResALL\sprites\SpriteGB.RAW" 
	endif
	ifdef BuildMSX_MSX1VDP
		incbin "\ResALL\sprites\RawMSX1.RAW" 
	endif
	ifdef BuildMSX_MSXVDP
		incbin "\ResALL\sprites\RawMSXVdp.RAW"
	endif
	ifdef BuildCPC;V9K only
		incbin "\ResALL\sprites\RawMSXVdp.RAW"
	endif
	ifdef BuildSMS
		incbin "\ResALL\Sprites\RawSMS.RAW"
		incbin "\ResALL\Sprites\SpriteSMS.RAW"
	endif
	ifdef BuildSGG
		incbin "\ResALL\Sprites\RawSMS.RAW"
		incbin "\ResALL\Sprites\SpriteSMS.RAW"
	endif

SpriteDataEnd:
HWSpriteData:
	ifdef BuildMSX_MSX1
	incbin "\ResALL\Sprites\SpriteMSX1.Raw"
	
	endif
	
	ifdef BuildCPC
	incbin "\ResALL\Sprites\SpriteCPC.PLS"
	endif
HWSpriteDataEnd:


	;2 bit bitmap font, this is generic for all systems
BitmapFont:
	ifdef BMP_UppercaseOnlyFont
		incbin "..\ResALL\Font64.FNT"			;Font bitmap, this is common to all systems
	else
		incbin "..\ResALL\Font96.FNT"			;Font bitmap, this is common to all systems
	endif
Message: db 'Hello World wxx!',255
	ifndef BuildCPC
		read "..\SrcALL\V1_VdpMemory.asm"	
		read "..\SrcALL\V1_HardwareTileArray.asm"
	endif
	
	align32	
KeyMap equ KeyMap2+16			;wsad bnm p
KeyMap2:						;Default controls
	ifdef BuildCPC
	db &F7,&03,&7f,&05,&ef,&09,&df,&09,&f7,&09,&fB,&09,&fd,&09,&fe,&09 ;p2-pause,f3,f2,f1,r,l,d,u
	db &f7,&03,&bf,&04,&bf,&05,&bf,&06,&df,&07,&df,&08,&ef,&07,&f7,&07 ;p1-pause,f3,f2,f1,r,l,d,u
KeyboardScanner_KeyPresses
	ds 16
	endif
	
MonitorRam equ &DF00
Monitor_TMP1 					equ MonitorRam; &C011
Monitor_NextMonitorPos_2Byte	equ MonitorRam+2;&C012;-13
Monitor_EI_Reenable_2byte 		equ MonitorRam+4;&C014;-5
Monitor_Special					equ MonitorRam+6;&C016

	
Monitor_Pause equ 1 				;*** Pause after showing debugging info
	read "..\SrcALL\Multiplatform_ShowHex.asm"
	read "..\SrcALL\Multiplatform_Monitor_RomVer.asm"
	read "..\SrcALL\Multiplatform_MonitorMemdump.asm"
	
	
	ifdef BuildCPC
		read "..\SrcALL\Multiplatform_BitmapFonts.asm"
		read "..\SrcALL\V1_BitmapMemory.asm"
UseHardwareKeyMap equ 1 ; Need the Keyboard map
		read "..\SrcAll\Multiplatform_ReadJoystick.asm"
		read "..\SrcCPC\CPCPLUS_V1_Palette.asm"
		read "..\SrcCPC\CPCPLUS_V1_Sprites.asm"
	
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	read "..\SrcALL\V2_Functions.asm"
	read "..\SrcALL\V1_Footer.asm"
