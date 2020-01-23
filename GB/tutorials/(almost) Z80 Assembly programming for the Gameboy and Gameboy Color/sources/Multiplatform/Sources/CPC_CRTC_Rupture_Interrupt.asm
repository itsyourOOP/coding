nolist
;
; Ma premiere Rupture ligne a ligne corrigee
; ---Ast/iMPACT Juillet 2017
;
;     org &1000

;NoStartRelocate equ 1
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
	
	

	
	;Screenmode switches - These will SLOW down your program due to delays needed to sync the mode change to the split
	
R1_Mode equ 1			
R2_Mode equ 0
R3_Mode equ 1
R4_Mode equ 0
R5_Mode equ 1
R6_Mode equ 0

R1_Addr equ &3011
R2_Addr equ &1020
R3_Addr equ &3000
R4_Addr equ &1015
R5_Addr equ &3000
R6_Addr equ &1003

MakeBorders equ 1	;Fake Vertical borders - hides R1 and equal amount of R6

	di


	Call DOINIT			;Get ready
	call ScreenINIT

	;Self modify in the address of the first interrupt handler
	im 1					
	ld A,&c3			;JP command
	ld (&0038),A			
	ld hl,Interrupt1	;Address of 1st Interrupt handler
	ld (&0039),hl
	ei

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;				Put Your Testcode Here
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	ld b,20
	ld a,'1'
TestChar:
	call printchar		;Line numbers
	inc a
	call newLine
	djnz TestChar

	



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Create some color flipped data

	ld hl,&C000		;Make a color flipped version at &4000
	ld de,&4000
	ld bc,&4000
FillAgain:
	ld a,(hl)
	cpl
	and &0f
	ld (de),a
	inc hl
	inc de
	dec bc
	ld a,b
	or c
	jr nz,FillAgain

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
						

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Hardware scroll strip 2 to the left

Infloop
	ld a,(Int2Addr_Plus2-2)
	inc a
	cp 41
	jr nz,InfloopB
	ld a,1
InfloopB:
	ld (Int2Addr_Plus2-2),a

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Hardware scroll strip 4 to the right

	ld a,(Int4Addr_Plus2-2)
	dec a
	cp 1
	jr nz,InfloopC
	ld a,41
InfloopC:
	ld (Int4Addr_Plus2-2),a

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Bounce Vscroll scroll Strip 3

	ld HL,(Int3Addr_Plus2-2)
	ld de,40
	or a			;Clear Carry
	adc hl,de ;<-- SM ***
VscrollDir_Plus1:
	ld a,h
	cp &31
	jr nz,InfloopD
	ld a,&52		;Change to SBC
	ld (VscrollDir_Plus1-1),a
InfloopD:
	ld a,h
	cp &30
	jr nz,InfLoopE
	ld a,l
	cp &00
	jr nz,InfLoopE
	ld a,&5a		;Change to ADC
	ld (VscrollDir_Plus1-1),a
InfLoopE
	ld (Int3Addr_Plus2-2),hl

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Draw text onscreen at &C000

	ld hl,0
	call locate
	ld a,c
	ld b,32
CharAgain
	call printChar		;Show some test data so we can see how fast the screen is drawing
	djnz CharAgain
	inc c
	jp Infloop



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;			Leave this part alone!

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Interrupt1:
	exx
	ex af,af'
		ld hl,Interrupt2	;Set address of next Handler
		ld (&0039),hl		;Mod interrupt jump

ifdef MakeBorders
	ld bc,&bc06				;Vertical Displayed
	out (c),c		
	ld bc,&bd00
	out (c),c	
endif
		ld b,&f5			;Read in Vsync State
Interrupt1_Vsync
		in a,(c)
		rra			
		jr nc,Interrupt1_Vsync	;Wait for Vsync
	


		ld b,8*2			;Wait for Vsync to finish
IntDelay1b	ds 60			;otherwise some CRTC have problems
		djnz IntDelay1b

		ld bc,&bc04			;Vertical Total (VTOT)
		out (c),c
		ld bc,&bd00+5-1		;Height of block -1
		out (c),c

		ld hl,R2_Addr
Int2Addr_Plus2:		
		ld bc,&bc0c			;Display Start Address (H)
		out (c),c
		inc b
		out (c),h

		dec b				;Display Start Address (L)
		inc c
		out (c),c
		inc b
		out (c),l

		ld bc,&bc07			;Vertical Sync position (VSYNC)
		out (c),c
		ld bc,&bdff			;Set VSCYNC=255 (Impossible...Disables Vsync)
		out (c),c

		
		
	ifdef R1_Mode
		ld bc,&7F00+128+4+8+R1_Mode
		out (c),c		;Change screen mode
	endif

	ifdef R2_Mode		;Screenmode change does not occur at the same time as the 
		ld b,8*2+4		;rupture, We need to delay to correct this by waiting (slow)	
IntDelay1	ds 60		;NOPS
		djnz IntDelay1

		ld bc,&7F00+128+4+8+R2_Mode
		out (c),c		;Change screen mode
	endif
ifdef MakeBorders
	ld bc,&bc06				;Vertical Displayed
	out (c),c		
	ld bc,&bd19
	out (c),c	
endif
	ex af,af'
	exx
	ei 
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Interrupt2:
	exx
	ex af,af'
		ld hl,Interrupt3	;Set address of next Handler
		ld (&0039),hl		;Mod interrupt jump

		ld bc,&bc04			;Vertical Total (VTOT)
		out (c),c
		ld bc,&bd00+6-1		;Height of block -1
		out (c),c

		ld hl,R3_Addr	;<-SM ***
Int3Addr_Plus2:
		ld bc,&bc0c			;Display Start Address (H)
		out (c),c
		inc b
		out (c),h

		dec b				;Display Start Address (L)
		inc c
		out (c),c
		inc b
		out (c),l

		ifdef R3_Mode		;Screenmode change does not occur at the same time as the
			ld b,8*4		;rupture, We need to delay to correct this by waiting (slow)
IntDelay2		ds 60		;NOPS
			djnz IntDelay2

			ld bc,&7F00+128+4+8+R3_Mode	
			out (c),c		;Change screen mode
		endif
	ex af,af'
	exx
	ei
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Interrupt3:
	exx
	ex af,af'
		ld hl,Interrupt4	;Set address of next Handler
		ld (&0039),hl		;Mod interrupt jump

		ld bc,&bc04			;Vertical Total (VTOT)
		out (c),c
		ld bc,&bd00+7-1		;Height of block -1
		out (c),c

		ld hl,R4_Addr
Int4Addr_Plus2:
		ld bc,&bc0c			;Display Start Address (H)
		out (c),c
		inc b
		out (c),h

		dec b				;Display Start Address (L)
		inc c
		out (c),c
		inc b
		out (c),l

		ifdef R4_Mode		;Screenmode change does not occur at the same time as the rupture
			ld b,9*4		;We need to delay to correct this by waiting (slow)
IntDelay3		ds 60		;NOPS
			djnz IntDelay3

			ld bc,&7F00+128+4+8+R4_Mode
			out (c),c	;Change screen mode
		endif 
	ex af,af'
	exx
	ei
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Interrupt4:
	exx
	ex af,af'
		ld hl,Interrupt5	;Set address of next Handler
		ld (&0039),hl		;Mod interrupt jump

		ld bc,&bc04			;Vertical Total (VTOT)
		out (c),c
		ld bc,&bd00+6-1		;Height of block -1
		out (c),c

		ld hl,R5_Addr
Int5Addr_Plus2:
		ld bc,&bc0c		;Display Start Address (H)
		out (c),c
		inc b
		out (c),h

		dec b			;Display Start Address (L)
		inc c
		out (c),c
		inc b
		out (c),l

		ifdef R5_Mode		;Screenmode change does not occur at the same time as the rupture
			ld b,8*4		;We need to delay to correct this by waiting (slow)
IntDelay4		ds 60		;NOPS
			djnz IntDelay4

			ld bc,&7F00+128+4+8+R5_Mode
			out (c),c		;Change screen mode
		endif
	ex af,af'
	exx
	ei
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Interrupt5:
	exx
	ex af,af'
		ld hl,Interrupt6	;Set address of next Handler
		ld (&0039),hl		;Mod interrupt jump

		ld bc,&bc04			;Vertical Total (VTOT)
		out (c),c
		ld bc,&bd00+7-1		;Height of block -1
		out (c),c

		ld hl,R6_Addr
Int6Addr_Plus2:
		ld bc,&bc0c			;Display Start Address (H)
		out (c),c
		inc b
		out (c),h

		dec b				;Display Start Address (L)
		inc c
		out (c),c
		inc b
		out (c),l

		ifdef R6_Mode		;Screenmode change does not occur at the same time as the rupture
			ld b,8*4+4		;We need to delay to correct this by waiting (slow)	
IntDelay5		ds 60		;NOPS
			djnz IntDelay5

			ld bc,&7F00+128+4+8+R6_Mode
			out (c),c	;Change screen mode
		endif 
	ex af,af'
	exx
	ei
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Interrupt6:
	exx
	ex af,af'

ifdef MakeBorders
	ld bc,&bc06				;Vertical Displayed
	out (c),c		
	ld bc,&bd06
	out (c),c	
endif

		ld hl,Interrupt1	;Set address of next Handler
		ld (&0039),hl		;Mod interrupt jump

		ld bc,&bc04			;Vertical Total (VTOT)
		out (c),c
		ld bc,&bd00+8-1		;Height of block -1
		out (c),c

		ld hl,R1_Addr
Int1Addr_Plus2:
		ld bc,&bc0c		;Display Start Address (H)
		out (c),c
		inc b
		out (c),h

		dec b			;Display Start Address (L)
		inc c
		out (c),c
		inc b
		out (c),l

		ld bc,&bc07		;Vertical Sync position (VSYNC)
		out (c),c		
		ld bc,&bd00		;Set VSCYNC=0 (Causes Vsync)
		out (c),c	

	ex af,af'
	exx
	ei
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
