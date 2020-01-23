	nolist

BuildCPC equ 1	; Build for Amstrad CPC


;ScrColor16 equ 1
;ScrWid256 equ 1


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
	

	Call DOINIT	; Get ready


	call ScreenINIT
	di
	ld a,&C9		;Disable the firmware interrupt handler
	ld (&0038),a
	
	
	ld hl,&4000		;Put some test data at &4000 (so we can see it)
	ld de,&4001
	ld bc,32
	ld (hl),&0F
	ldir
	

	ld a,17			;Color the border
	ld hl,&0800
	call SetPalette

	call CLS

	ld hl,&FE00		;Put some test data at &FE00 (so we can see it)
	ld de,&FE01
	ld bc,256
	ld (hl),&F0
	ldir

	ld hl,&FF00		;Put some test data at &FF00 (so we can see it)
	ld de,&FF01
	ld bc,256
	ld (hl),&0F
	ldir

	ld hl,&7F00		;Put some test data at &7F00 (so we can see it)
	ld de,&7F01
	ld bc,&32
	ld (hl),255
	ldir
Again:
	ld hl,&0000			;Relocate to top of screen
	call Locate

	ld hl,TitleLine		;Show Title line
	call PrintString
	Call Newline

	ld hl,CRTCParams	;Parameters
ShowCRTCAgain:
	ld a,(hl)
	call printchar		;Show +- button
	inc hl
	ld a,(hl)
	call printchar
	inc hl
	call PrintSpace

	ld e,(hl)			;Show reg name
	inc hl
	ld d,(hl)
	inc hl
	push hl
	 	ex de,hl
		call PrintString
	pop hl
	ld a,(hl)
	
	push hl
		call ShowDecimal ; Show Reg Num
	pop hl
	inc hl
	call PrintSpace
	ld a,(hl)
	push hl
		call showDecimal	;Show Reg value in DEC
	pop hl
	call PrintSpace
	ld a,(hl)
	call showHex			;Show Reg value in HEX
	inc hl

	call NewLine
	ld a,(hl)
	cp 255					;Repeat until 255
	jr nz,ShowCRTCAgain

	Call Newline

	ld hl,Extra
	call PrintString		;Safemode string

	call waitchar
	ld ixl,a
	cp '0'
	jr nz,NoSafe
	ld a,iyl		;Toggle safe mode
	cpl
	ld iyl,a
NoSafe:
	
	ld hl,CRTCParams
SetCRTCAgain:
	ld ixh,0
	
	ld a,(hl)		;See if Down button was pressed
	inc hl
	cp ixl	
	jr nz,NotLower
	dec ixh
NotLower:

	ld a,(hl)		;See if up button was pressed
	inc hl
	cp ixl
	jr nz,NotHigher
	inc ixh
NotHigher:

	inc hl
	inc hl
	ld c,(hl)		;Get Reg Num
	inc hl
	ld a,(hl)		;Get Reg Val
	add ixh			;Alter Reg Val
	ld (hl),a
	inc hl
	Call SetCRTC	;C=RegNum A=RegVal 
	ld a,(hl)
	cp 255			;Repeat if not 255
	jr nz,SetCRTCAgain

	ld a,iyl		;IYL=0 means safe mode is off
	or a
	jp z,Again		

	ld bc,&8000		;Wait a while
PauseAgain:
	nop
	nop
	dec bc
	ld a,b
 	or c
	jr nz,PauseAgain

	ld hl,SafeParams	;Reset Safe parameters
SafeParamsAgain:
	ld c,(hl)
	inc hl
	ld a,(hl)
	inc hl
	Call SetCRTC	;C=RegNum A=RegVal 
	ld a,(hl)
	cp 255
	jr nz,SafeParamsAgain

	jp Again
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SetCRTC:
	ld b,&BC		;&BC=CRTC Reg select
	out (c),c
	inc b			;&BD=CRTC Val select
	out (c),a
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CRTCParams:			;CRTC Settings 

	db '12'			;-+ Buttons
		dw Htotal	;Label address
		db &00,63	;Reg,Val
	db 'QW'
		dw HDisp
		db &01,40
	db 'AS'
		dw HSyncPos
		db &02,46
	db 'ZX'
		dw HVSyncWidth
		db &03,128+14
	db '45'
		dw VTotal
		db &04,38
	db 'RT'
		dw VAdjust
		db &05,0
	db 'FG'
		dw VDisp
		db &06,25
	db 'VB'
		dw VSync
		db &07,30
	db '78'
		dw IntSkw
		db &08,0
	db 'UI'
		dw MaxAddr
		db &09,7
	db 'JK'
		dw AddrH
		db &C,&30
	db 'M,'
		dw AddrL
		db &D,0
	db 255			;End of list

SafeParams:
		db &00,63	;Reg,Val
		db &01,40
		db &02,46
		db &03,128+14
		db &04,38
		db &05,0
		db &06,25
		db &07,30
		db &08,0
		db &09,7
		db &C,&30
		db &D,0
	db 255			;End of list

	
					;Label strings
Htotal: 	db "Htotal......",255
HDisp: 		db "HDisp.......",255
HSyncPos: 	db "HSyncPos....",255
HVSyncWidth:db "HVSyncWidth.",255
VTotal:		db "VTotal......",255
VAdjust:	db "VAdjust.....",255
VDisp:		db "VDisp.......",255
VSync:		db "VSync.......",255
IntSkw:		db "IntSkw......",255
MaxAddr:	db "MaxAddr.....",255
AddrH:		db "AddrH.......",255
AddrL:		db "AddrL.......",255

				;Extra Lines
TitleLine:	db "-+ Name        Reg Val &VL",255
Extra:		db "0=SafeMode ",255

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
