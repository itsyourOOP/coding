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
	
	ld hl,&0500
	ld (CursorMinX),hl				;Set Min/Max X positions (h=max l=min)
	
	ld hl,&1400
	ld (CursorMinY),hl				;Set Min/Max Y positions (h=max l=min)
	
	ld hl,&0101
	ld (CursorMoveSpeedXY),hl		;Set cursor speed (h=Xspeed,l=Yspeed)

	ld hl,&0F0B
	ld (BallXY),hl					;Set Ball pos
	
	ld hl,&FF01
	ld (BallMove),hl				;Set ball Move Dir H=X, L=Y.... 1=+1 FF=-1
	
	ld hl,&1E10
	ld (CpuPos),hl					;CPU Pos
MainLoop:	
	
	ld hl,(BallXY)			;Load the Ball pos
	ld a,' '
	call DrawBall			;Clear the ball
	
	ld hl,(CursorCurrentPosXY)	;Load the Player paddle pos
	ld a,' '
	call DrawPaddle			;Clear the player paddle
	
	
	ld hl,(CpuPos)			;Clear the CPU paddle
	ld a,' '
	call DrawPaddle
	
	ld hl,(CpuPos)			;Get CPU pos
	ld bc,(BallXY)			;Get BallPos
	
	ld a,c					;We want to see how ball Y compares to CPU bat
	dec c
	cp l					;Compare Ballpos to batpos
	
	jr z,Cpumatch			;CPU paralell with ball
	jr c,CpuLow				;CPU Lower than ball
	
CpuHigh:					;If we got her CPU is Higher than ball
		ld a,l		
		cp 23-4 			;Check CPU isn't going offscreen!
		jr nc,Cpumatch
		inc l				;Move CPU Down
		jr Cpumatch
CpuLow:
		dec l				;Move CPU UP
Cpumatch:	
	ld (CpuPos),hl			;Save the new CPU pos
	
	call Player_ReadControlsDual	;Read in the controllers
	ld a,h
	and l
	ld h,a			;Read both controllers, and merge them together into H	
	
	ld de,(CursorCurrentPosXY)		;Update Last cursor Data
	call Cursor_ProcessDirections	;Process the Movement directions
	ld (CursorCurrentPosXY),de		;Save the new Cursor Position
	
	ld hl,(BallXY)			;Ball X,Y pos
	ld bc,(BallMove)		;Ball Move X,Y
	ld de,&0000				;Flip direction X,Y... <>0 = flip direction
		
	ld a,h					;Move Ball X
	add b
	ld h,a
	
	cp 32
	jr z,BallOverXCpu		;Ball in CPU Goal
	cp -1
	jr z,BallOverXPlayer	;Ball in Player Goal
	jr BallNotOverX
	
BallOverXPlayer:
	ld hl,Score+1			;Add1 to player score
	jr BallOverX
BallOverXCpu:
	ld hl,Score				;Add one to CPU score
BallOverX:
	inc (hl)				;Increase Score
	inc d					;Remember we want to flip X of ball
	ld hl,&0F0B
	ld (BallXY),hl			;Reset ball Pos
BallNotOverX:

	ld a,l					;Move Ball Y
	add c
	ld l,a
	
	cp 23
	jr z,BallOverY			;See if Ball has hit bottom of screen
	cp 0
	jr z,BallOverY			;See if Ball has hit top of screen
	jr BallNotOverY
	
BallOverY:	
	inc e					;Remeber we want to flip the Y of ball
BallNotOverY:
	ld (BallXY),hl			;Save the new ball position

	push bc	
		ld bc,(CursorCurrentPosXY)
		call CheckPaddleHit			;See if Ball hit player
		ld bc,(CpuPos)
		call CheckPaddleHit			;See if Ball hit CPU
	pop bc
	
	ld a,e					;If E>0 we'll flip ball move Y
	or a
	jr z,DontFlipBallY
	
	ld a,c
	neg						;Flip Ball Move Y
	ld c,a
DontFlipBallY:
	
	ld a,d					;If D>0 we'll flip ball move X
	or a
	jr z,DontFlipBallX	
	
	ld a,b
	neg						;Flip Ball Move X
	ld b,a
DontFlipBallX:
	ld (BallMove),bc		;Save updated Ball Move
	
	
	ld hl,&0C00				;Move text cursor to Top-Center
	call Locate
	
	ld hl,(Score)			
	ld a,l
	call ShowHex			;Show Player Score
	ld a,":"
	call PrintChar
	ld a,h
	call ShowHex			;Show CPU Score
	
	ld hl,(BallXY)
	ld a,'O'
	call DrawBall			;Draw the Ball
	
	ld hl,(CpuPos)			;Draw the CPU Paddle
	ld a,'X'
	call DrawPaddle
	
	ld hl,(CursorCurrentPosXY) ;Draw the player paddle
	ld a,'X'
	call DrawPaddle
	
	ld bc,10000				;Pause for a while
	call Pause
	
	jp MainLoop
	
DrawBall:
	call locate				;Draw the ball (char in A)
	call printchar
	ret
	
DrawPaddle:					;Draw the paddle (char in A)
	ld b,4					;Paddle Length
DrawPaddleAgain:
	call locate
	call printchar			
	inc l					;Move Ypos down
	djnz DrawPaddleAgain
	ret

	
CheckPaddleHit:				;Test if Ball hit paddle at BC (X,Y)
	ld hl,(BallXY)			;Load Ball Pos into HL
	
	ld a,b			;See if ball is on same X position as Paddle
	cp h
	ret nz			;Return if NO

	ld a,l			;Compare Ypos of ball to Ypos of paddle
	cp c					
	ret c			;Return if ball is above paddle
	
	inc c			;Add 4 to paddle Y
	inc c
	inc c
	inc c
	cp c			;Compare ball to pos of bottom of paddle
	ret nc			;Return if ball Y is higher
				
	inc d			;Flip X pos
	ld a,r
	and %00001000
	ld e,a			;Randomize Y pos
	ret

BallXY: 	dw &0000			;Ball position
BallMove: 	dw &0101			;Ball Move (X,Y)
	
Score: 		dw &0000			;Score (player,cpu)

CpuPos: 	dw &1E10			;CPU Paddle pos
CursorCurrentPosXY:	dw &0808	;Player Paddle pos
	
CursorMinX: 	db 1			;Player Move limits
CursorMaxX: 	db 10
CursorMinY: 	db 1
CursorMaxY: 	db 10

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
	