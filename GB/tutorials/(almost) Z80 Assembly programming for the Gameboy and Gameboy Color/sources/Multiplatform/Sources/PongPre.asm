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

	ifdef BuildSMS
BuildCONSOLE 	equ 1
BuildCONSOLEjoy	equ 1
BuildSxx 		equ 1

	endif
	ifdef BuildSGG
BuildCONSOLE 	equ 1
BuildCONSOLEjoy	equ 1
BuildSxx 		equ 1
ScreenSmall 	equ 1
	endif
	ifdef BuildGMB
PaletteGB 		equ 1
BuildCONSOLE 	equ 1
BuildCONSOLEjoy	equ 1
BuildGBx 		equ 1
ScreenSmall 	equ 1
	endif
	ifdef BuildGBC
PaletteGB 		equ 1
BuildCONSOLE 	equ 1
BuildCONSOLEjoy	equ 1
BuildGBx 		equ 1
ScreenSmall 	equ 1
	endif
	ifdef BuildCPC
Palette4 		equ 1
	endif
	ifdef BuildENT
Palette4 		equ 1
	endif
	ifdef BuildTI8
ScreenSmall 	equ 1
	endif
	ifdef BuildMSX
		ifdef BuildMSX_MSX1
BuildMSX_MSX1VDP equ 1						;Disable these to use Software screen on MSX1
BuildCONSOLE 	equ 1						;Disable these to use Software screen on MSX1
		else
	ifdef BuildMSX
BuildMSX_MSXVDP equ 1						;Disable these to use Software screen on MSX
BuildCONSOLE 	equ 1						;Disable these to use Software screen on MSX
	endif
;BuildMSX2 equ 1							;Turn off tile animation (not needed if using VDP option)
		endif
	endif
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef vasm
		include "..\SrcALL\VasmBuildCompat.asm"
	else
		read "..\SrcALL\WinApeBuildCompat.asm"
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	read "..\SrcALL\V1_Header.asm"
	ifdef BuildCONSOLE
		read "..\SrcALL\V1_VdpMemory_Header.asm"
	else
		read "..\SrcALL\V1_BitmapMemory_Header.asm"
	endif
	read "..\SrcALL\CPU_Compatability.asm"
	read "..\SrcALL\Multiplatform_ReadJoystick_Header.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	call ScreenINIT		;Enable the Bitmap Screen
	Call DOINIT	; Get ready
	
	
	ifndef BuildCONSOLEjoy
		call KeyboardScanner_Init				;Reset the controller buffer
		ifndef BuildZXS
			call KeyboardScanner_AllowJoysticks		;enable joystick support (disabled by default on speccy)
		endif
	endif
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	ld hl,&010B
	ld (CursorCurrentPosXY),hl		;Set Current player Position (H=Xpos , L=Ypos)
	
	ld hl,&0F00
	ld (CursorMinX),hl				;Set Min/Max X positions (h=max l=min)
	
	ld hl,&1400
	ld (CursorMinY),hl				;Set Min/Max Y positions (h=max l=min)
	
	ld hl,&0101
	ld (CursorMoveSpeedXY),hl		;Set cursor speed (h=Xspeed,l=Yspeed)

MainLoop:	
	ld hl,(CursorCurrentPosXY)	;Load the Player paddle pos
	ld a,' '
	call DrawPaddle					;Clear the player paddle

	call Player_ReadControlsDual	;Read in the controllers
	ld a,h
	and l							;Take Player 1 + 2 controls
	ld h,a							;and merge them together into H	
	
	ld de,(CursorCurrentPosXY)		;Update Last cursor Data
	call Cursor_ProcessDirections	;Process the Movement directions
	ld (CursorCurrentPosXY),de		;Save the new Cursor Position
	
	ld hl,(CursorCurrentPosXY) ;Draw the player paddle
	ld a,'X'
	call DrawPaddle
	
	ld bc,10000				;Pause for a while
	call Pause
	
	jp MainLoop
	
DrawPaddle:					;Draw the paddle (char in A)
	ld b,4					;Paddle Length
DrawPaddleAgain:
	call locate
	call printchar			
	inc l					;Move Ypos down
	djnz DrawPaddleAgain
	ret


CursorCurrentPosXY:	dw &010B	;Player Paddle pos
	
CursorMinX: 	db 0			;Player Move limits
CursorMaxX: 	db 5
CursorMinY: 	db 0
CursorMaxY: 	db 14

CursorMoveSpeedXY: dw &0101		;Player Move speed

	
	

	include "CA_Cursor_ProcessDirections.asm"
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
Pause:
      	dec bc
      	ld a,b
       	or c
      	jr nz,Pause				;Pause for BC ticks
       	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	;2 bit bitmap font, this is generic for all systems
BitmapFont:
	ifdef BMP_UppercaseOnlyFont
		incbin "..\ResALL\Font64.FNT"			;Font bitmap, this is common to all systems
	else
		incbin "..\ResALL\Font96.FNT"			;Font bitmap, this is common to all systems
	endif


	align32	
KeyMap equ KeyMap2+16			;wsad bnm p
KeyMap2:						;Default controls
	ifdef BuildCPC
	db &F7,&03,&7f,&05,&ef,&09,&df,&09,&f7,&09,&fB,&09,&fd,&09,&fe,&09 ;p2-pause,f3,f2,f1,r,l,d,u
	db &f7,&03,&bf,&04,&bf,&05,&bf,&06,&df,&07,&df,&08,&ef,&07,&f7,&07 ;p1-pause,f3,f2,f1,r,l,d,u
	endif
	ifdef BuildENT
	db &ef,&09,&bf,&08,&df,&0a,&bf,&0a,&fe,&0a,&fd,&0a,&fb,&0a,&f7,&0a
	db &ef,&09,&fe,&08,&fe,&00,&fb,&00,&f7,&01,&bf,&01,&df,&01,&bf,&02
	endif
	ifdef BuildZXS
	db &fe,&05,&fe,&07,&fe,&06,&ef,&08,&fe,&08,&fd,&08,&fb,&08,&f7,&08
	db &fe,&0f,&fb,&07,&f7,&07,&ef,&07,&fb,&01,&fe,&01,&fd,&01,&fd,&02
	endif
	ifdef BuildMSX
	db &df,&04,&fe,&08,&ef,&0c,&df,&0c,&f7,&0c,&fb,&0c,&fd,&0c,&fe,&0c
	db &df,&04,&fb,&04,&f7,&04,&7f,&02,&fd,&03,&bf,&02,&fe,&05,&ef,&05
	endif
	ifdef BuildTI8
	db &f7,&05,&fb,&05,&fd,&05,&fe,&05,&fb,&04,&fb,&02,&fd,&03,&f7,&03
	db &bf,&05,&7f,&00,&bf,&00,&df,&00,&fb,&06,&fd,&06,&fe,&06,&f7,&06
	endif
	ifdef BuildSAM
	db &FE,&05,&Fe,&07,&FE,&06,&FE,&04,&F7,&04,&EF,&04,&FB,&04,&FD,&04
	db &FE,&05,&FB,&07,&F7,&07,&EF,&07,&FB,&01,&FE,&01,&FD,&01,&FD,&02
	endif
	ifdef BuildCLX
		db &Fd,&07,&F7,&02,&F7,&09,&F7,&04,&DF,&09,&FB,&09,&DF,&00,&EF,&00
		db &Fd,&07,&F7,&02,&F7,&09,&F7,&04,&DF,&09,&FB,&09,&DF,&00,&EF,&00
	endif
	
KeyboardScanner_KeyPresses
	ds 16
	
	
	
	
MonitorRam equ &DF00
Monitor_TMP1 					equ MonitorRam; &C011
Monitor_NextMonitorPos_2Byte	equ MonitorRam+2;&C012;-13
Monitor_EI_Reenable_2byte 		equ MonitorRam+4;&C014;-5
Monitor_Special					equ MonitorRam+6;&C016

	
Monitor_Pause equ 1 				;*** Pause after showing debugging info
	read "..\SrcALL\Multiplatform_ShowHex.asm"
	read "..\SrcALL\Multiplatform_Monitor_RomVer.asm"
	read "..\SrcALL\Multiplatform_MonitorMemdump.asm"
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifndef BuildCONSOLEjoy
UseHardwareKeyMap equ 1 ; Need the Keyboard map
	endif
	
	ifdef BuildCONSOLE
		read "..\SrcALL\V1_VdpMemory.asm"
		read "..\SrcALL\V1_HardwareTileArray.asm"
	else

		;read "..\SrcALL\Multiplatform_ScanKeys.asm"
		;read "..\SrcALL\Multiplatform_KeyboardDriver.asm"
		ifndef BuildCLX
			read "..\SrcALL\Multiplatform_BitmapFonts.asm"
		endif
		read "..\SrcALL\V1_BitmapMemory.asm"
	endif
	align16

	read "..\SrcAll\Multiplatform_ReadJoystick.asm"
	
	read "..\SrcAll\V1_Palette.asm"
	read "..\SrcALL\V2_Functions.asm"
	read "..\SrcALL\V1_Footer.asm"
	