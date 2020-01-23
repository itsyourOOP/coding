

;Uncomment one of the lines below to select your compilation target

;BuildCPC equ 1	; Build for Amstrad CPC
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
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	read "..\SrcALL\CPU_Compatability.asm"
	read "..\SrcALL\V1_Header.asm"
	read "..\SrcALL\V1_BitmapMemory_Header.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

	Call DOINIT		;Get ready

	call ScreenINIT		;Enable the Bitmap Screen

	di
	ld hl,message
	call PrintString
		ld hl,message
	call PrintString
		ld hl,message
	call PrintString
		ld hl,message
	call PrintString

	
	ld bc,&0820
	call GetScreenPos
	
	ld hl,BitmapSprite
	ld ixh,6			;Width in blocks (8 pixel)
	ld ixl,48			;Height in pixels
	
	call ShowBitmap		;Show to bitmap to screen
	
	ld a,'!'
	call printChar
	
InfLoop:
	jr InfLoop

ShowBitmap:
	
	ld iyl,e	;Backup the destination - we can't use the stack here
	ld iyh,d
	
	ld b,0		;We use LDIR for our datacopy - we need b=0
	
ShowBitmapAgain:
	ScreenDrawRedBlue	;Set Memory up to draw Red/Blue 
	;DON'T USE THE STACK AFTER THIS POINT!!!
	 
	;call Testroutine ;- this will mess up!
	push hl
	push hl
	push hl
	push hl
	pop hl
	pop hl
	pop hl
	pop hl
	ld c,ixh	;Reset The Bytecount
	
	ldir		;Do Blue Component (&A000-&BFFF)
	 
	ld e,iyl	;Reset the Destination pos
	ld d,iyh

	set 6,d		;Move destination to &Cxxx
	res 5,d		;Note: because of the memory map, you can actually disable this line
	
	ld c,ixh	;Reset The Bytecount
	
	ldir		;Do Red Component (&C000-&DFFF)

	ld e,iyl	;Reset the Destination pos
	ld d,iyh
	 
	set 6,d		;Move destination to &Cxxx
	res 5,d		;Note: because of the memory map, you can actually disable this line
	
	ScreenDrawGreen	;Set Memory up to draw Green
	
	ld c,ixh	;Reset The Bytecount
	
	ldir		;Do Green Component (&C000-&DFFF)
	 
	ld bc,&0020	;Move Down a line (32 bytes per line)	
	add iy,bc
	
	ld e,iyl	;Reset the Destination pos
	ld d,iyh
	
	dec ixl
	jr nz,ShowBitmapAgain
	
	ScreenStopDrawing	;Set Memory up to Turn off drawing
	ret

Testroutine:
	ret	
	
message:
	db 'VASM SAYS HI',255

BitmapFont:
	ifdef BMP_UppercaseOnlyFont
		incbin "\ResALL\Font64.FNT"			;Font bitmap, this is common to all systems
	else
		incbin "\ResALL\Font96.FNT"			;Font bitmap, this is common to all systems
	endif
	
BitmapSprite:
	incbin "\ResALL\Sprites\RawCLX.raw"

Monitor_Full equ 1
gameram equ &6300	
MonitorRam 						equ GameRam
Monitor_TMP1 					equ MonitorRam; &C011
Monitor_NextMonitorPos_2Byte	equ MonitorRam+2;&C012;-13
Monitor_EI_Reenable_2byte 		equ MonitorRam+4;&C014;-5
Monitor_Special					equ MonitorRam+6;&C016

	
	
	read "\SrcALL\Multiplatform_MonitorMemdump.asm"
	read "\SrcALL\Multiplatform_Monitor_RomVer.asm"
	read "\SrcALL\Multiplatform_MonitorSimple_RomVer.asm"
	read "\SrcALL\Multiplatform_ShowHex.asm"
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	read "..\SrcALL\V1_BitmapMemory.asm"

	read "..\SrcALL\V1_Functions.asm"
	read "..\SrcALL\V1_Footer.asm"
