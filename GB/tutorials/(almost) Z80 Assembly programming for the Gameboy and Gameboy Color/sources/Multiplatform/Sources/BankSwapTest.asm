	nolist
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
ScrWid256 equ 1

;CpcPlus equ 1			;We can build for CPC plus if we want!


;For example of use on the Enterprise see : http://www.chibiakumas.com/z80/platform3.php#LessonP27


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef vasm
		include "..\SrcALL\VasmBuildCompat.asm"
	else
		read "..\SrcALL\WinApeBuildCompat.asm"
	endif
	read "..\SrcALL\CPU_Compatability.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	read "..\SrcALL\V1_Header.asm"
	ifdef BuildCONSOLE
		read "..\SrcALL\V1_VdpMemory_Header.asm"
	else
		read "..\SrcALL\V1_BitmapMemory_Header.asm"
	endif
	
	read "..\SrcALL\Multiplatform_ReadJoystick_Header.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef BuildTI8
ScreenWidthG equ ScreenWidth*2
ScreenHeightG equ ScreenHeight*2
	else
ScreenWidthG equ ScreenWidth
ScreenHeightG equ ScreenHeight
	endif
	
	ifdef BuildGBC
BuildCONSOLE equ 1
	endif
	
	ifdef BuildGMB
BuildCONSOLE equ 1
	endif
	
	ifdef BuildSGG
BuildCONSOLE equ 1
	endif
	ifdef BuildSMS
BuildCONSOLE equ 1
	endif
	
	

	ifdef BuildCONSOLE
	ifdef BuildMSX			;The starting memory address of the game ram depends on the system
GameRam equ &C000
	else
GameRam equ &D800
		endif
	else
		ifdef BuildMSX
GameRam equ &C000
		else
		ifdef BuildTI8
GameRam equ &F000
			else
GameRam equ &7000
			endif
		endif
	endif
	
	
MonitorRam 						equ GameRam
Monitor_TMP1 					equ MonitorRam; &C011
Monitor_NextMonitorPos_2Byte	equ MonitorRam+2;&C012;-13
Monitor_EI_Reenable_2byte 		equ MonitorRam+4;&C014;-5
Monitor_Special					equ MonitorRam+6;&C016

KeyboardScanner_KeyPresses		equ GameRam+16
UseSampleKeymap				equ 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	Call DOINIT				; Get ready
	call ScreenINIT			; Set up graphics screen
	di
	ifdef BuildZXS
		ld sp,&BFFF
	endif
	ifdef BuildSAM
		ld sp,&BFFF
	endif

	
	ld a,&C9
	ld (&0038),a			;Disable internal hardware interrupts, we don't need them!
	di
	call GetHardwareVer
	call monitor
	
	;
	ifdef BuildGBC
		call EnableFastCPU
	endif
	
	
			
			
		
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef BuildSAM
BasicRamTest equ 1
	endif
	ifdef BuildZXS
BasicRamTest equ 1
	endif	
	ifdef BuildSMS
BasicRamTestSMS equ 1
BasicRamTest equ 1
	endif	
	ifdef BuildSGG
BasicRamTestSMS equ 1
BasicRamTest equ 1
	endif	
	ifdef BuildGMB
BasicRamTestGB equ 1
	endif	
	ifdef BuildGBC
BasicRamTestGB equ 1
	endif	
	
		
	ifdef BasicRamTestSMS
		ld a,RamBank0
		call SMSCartBank
		
		ld a,RamBank0
		ld (RamBankBase),a
			
		ld a,RamBank1
		call SMSCartBank
		
		ld a,RamBank1
		ld (RamBankBase),a
		
		
		ld a,RamBankOff
		call SMSCartBank
		
		call Monitor_MemDump
			db 16
			dw RamBankBase
		
		ld a,RamBank0
		call SMSCartBank
		
		call Monitor_MemDump
			db 16
			dw RamBankBase
		
		ld a,RamBank1
		call SMSCartBank
		
		call Monitor_MemDump
			db 16
			dw RamBankBase
		
		ld a,RamBankOff
		call SMSCartBank
	endif
	
	ifdef BasicRamTestGB
		ld a,0	
		call GBCart_RamBank
		ld a,&69
		ld (&A000),a
		
		call Monitor_MemDump
		db 16
		dw &A000
	
		ld a,Bank1							;Set a byte of bank 1
		call BankSwitch_SetCurrent
		call Monitor_MemDump
		db 16
		dw BankBase
		ld a,Bank2							;Set a byte of bank 1
		call BankSwitch_SetCurrent
		call Monitor_MemDump
		db 16
		dw BankBase
	endif
		
	ifdef BasicRamTest
	
		ld a,Bank1							;Set a byte of bank 1
		push af
			call BankSwitch_SetCurrent
		pop af
		ld (BankBase),a
		
		ld a,Bank2							;Set a byte of bank 2
		push af
			call BankSwitch_SetCurrent
		pop af
		ld (BankBase),a
		
		call NewLine
		ld a,Bank0							;Show the contents of bank 0
		call BankSwitch_SetCurrent
		call Monitor_MemDump
		db 16
		dw BankBase
		
		
		call NewLine
		ld a,Bank1							;Show the contents of bank 1
		call BankSwitch_SetCurrent
		call Monitor_MemDump
		db 16
		dw BankBase
		
		call NewLine
		ld a,Bank2							;Show the contents of bank 2
		call BankSwitch_SetCurrent
		call Monitor_MemDump
		db 16
		dw BankBase
	
	endif
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	ifdef BuildCPC
	
		ld a,Bank1							;Set a byte of bank 1
		push af
			call BankSwitch_SetCurrent
		pop af
		ld (BankBase),a
		
		ld a,Bank2							;Set a byte of bank 2
		push af
			call BankSwitch_SetCurrent
		pop af
		ld (BankBase),a
		
		call NewLine
		ld a,Bank0							;Show the contents of bank 0
		call BankSwitch_SetCurrent
		call Monitor_MemDump
		db 16
		dw BankBase
		
		
		call NewLine
		ld a,Bank1							;Show the contents of bank 1
		call BankSwitch_SetCurrent
		call Monitor_MemDump
		db 16
		dw BankBase
		
		call NewLine
		ld a,Bank2							;Show the contents of bank 2
		call BankSwitch_SetCurrent
		call Monitor_MemDump
		db 16
		dw BankBase
	
		ld a,5								;Lets get Cartridge bank 5
		call BankSwapper_SetCartBank		;Page in cartrige rom to &C000
	endif
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	
	ifdef BuildMSX
	di
	call NewLine
			
;	call GetCurrentBank
;	ld (CurrentRunningBank_Plus1-1),a

;lets play with the cartridges
		ld a,3
		call BankSwapper_SetCartBank

		call Monitor_MemDump
		db 16
		dw &4000
				
		ld a,5
		call BankSwapper_SetCartBank
		
		call Monitor_MemDump
		db 16
		dw &4000
		
		
	
	
	
		call NewLine
		ld sp,AltStack
		call BankSwapper_FindRAM
		
		; H=Page
		; L=Slot
		; D=subslot
		;di
		;halt
		; ld h,0
; BankTesth
		; ; push hl
			; ; ld a,'*'
			; ; call printchar
		
			; ; ld a,h
			; ; add '0'
			; ; call printchar
			; ; ld a,'*'
			; ; call printchar
		; ; pop hl
		; ld l,0
; BankTestl
		; ; push hl
			; ; ld a,l
			; ; add '0'
			; ; call printchar
			; ; ld a,':'
			; ; call printchar
		; ; pop hl

		; ld d,0
; BankTestD:
		; push hl
			; call BankTest
			; call ShowBankSummary
		; pop hl
		; cp 2
		; jr z,FoundRam
		; inc d
		; ld a,d
		; cp 4
		; jr nz,BankTestD
	; ;	push hl
		; ;	ld a,' '
		; ;	call printchar
		; ;pop hl
		; inc l
		; ld a,l
		; cp 4
		; jr nz,BankTestL
		; jr NoRamFound
; FoundRam:
		; call BackupSlotRegisters
; NoRamFound:
		; ; push hl
			; ; call NewLine
		; ; pop hl
	
		; inc h
		; ld a,h
		; cp 0	;<-- SM ***		;We can't bank switch the CURRENT bank - unless we like crashes!
; CurrentRunningBank_Plus1:
		; jr nz,DontskipHbank

		; inc h
; DontskipHbank:		
		
		; cp 4
		; jr nz,BankTestH
		
; ;		call Bankswapper_FullRam


; infloop:		
		
		; jp infloop


; GetCurrentBank:
		; pop hl
		; push hl
		; ld a,h
		; rlca
		; rlca
		; and %00000011
		; ret
		
; ShowBankSummary:
		 ; push hl
		 ; push de
	 		; ld a,h
			; rrca
			; rrca
			; and %11000000
			; ld h,a
			; ld l,0
			; ld d,0
			; ld a,(hl)
			; cpl
			; ld (hl),a
			; cp (hl)
			; jr nz,ShowBankSummaryReadOnly
			; cpl
			; ld (hl),a
			; ld d,2
; ShowBankSummaryReadOnly:
			
			; ; ld a,e 
			; ; or d
			; ; add '0'
			; ; call printchar
			 ; ld a,d
		 ; pop de
		 ; pop hl
		; ret

	endif
	
	;call Monitor_MemDump
	;db 16
	;dw BankBase
	
	; ld a,(&5B5C)	;+3 memory mode won't allow access to this bank
	; ld e,a
	; ld a,(&5B67)
	; ld d,a
		; ;---SDR-P		P = paging mode 0=normal	R=Rom high bit	D = Disk Motor	S=Printer strobe
	; and %11111000
	; or  %00000001	;We're going to page in +3 option 00 = Bank 0/1/2/3 - this will make the stack and screen inaccessible
	
	; ld bc,&1FFD
	; out (c),a
	
	; ld a,e
	; and  %11111000	;Page in Bank 0 on the regular 128
	; ld bc,&7FFD
	; out (c),a
	
	; ld a,(BankBase) ;Flip the bits of &C000 - this will affect Bank 0 on a 128, or bank 3 on a +3
	; cpl
	; ld (BankBase),a
	
	; ld a,d			;Reset banking!
	; ld bc,&1FFD
	; out (c),a
	
	; ld a,e			;Reset banking!
	; ld bc,&7FFD
	; out (c),a
	
	; ld a,(BankBase) ; Read back - if it's &69 - we're on a+3
	; call monitor
	
	
	
	
	di
	halt
	ifdef BuildMSX
	ds 64
AltStack:	
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BitmapFont:
	ifdef BMP_UppercaseOnlyFont
		incbin "..\ResALL\Font64.FNT"			;Font bitmap, this is common to all systems
	else
		incbin "..\ResALL\Font96.FNT"			;Font bitmap, this is common to all systems
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Monitor_Pause equ 1 				;*** Pause after showing debugging info


	read "..\SrcALL\Multiplatform_MonitorMemdump.asm"
	read "..\SrcALL\Multiplatform_Monitor_RomVer.asm"
	read "..\SrcALL\Multiplatform_MonitorSimple_RomVer.asm"
	read "..\SrcALL\Multiplatform_ShowHex.asm"
	
	read "..\SrcALL\V1_BankSwapper.asm"
	read "..\SrcALL\V1_GetHardwareVer.asm"
	
	ifdef BuildGBC
		read "..\SrcGB\GB_V1_CpuTurbo.asm"
	endif
	
	
	
	;read "..\SrcCPC\CPC_V1_BankSwapper.asm"
	;read "..\SrcCPC\CPC_V1_GetHardwareVer.asm"
	
	;read "..\SrcZX\ZX_V1_BankSwapper.asm"
	;read "..\SrcZX\ZX_V1_GetHardwareVer.asm"
	
	;read "..\SrcENT\ENT_V1_BankSwapper.asm"
	;read "..\SrcENT\ENT_V1_GetHardwareVer.asm"
	
	;read "..\SrcSAM\SAM_V1_BankSwapper.asm"
	;read "..\SrcSAM\SAM_V1_GetHardwareVer.asm"
	
	;read "..\SrcGB\GB_V1_BankSwapper.asm"
	;read "..\SrcGB\GB_V1_GetHardwareVer.asm"

	;read "..\SrcSMS\SMS_V1_BankSwapper.asm"
	;read "..\SrcSMS\SMS_V1_GetHardwareVer.asm"


	;read "..\SrcMSX\MSX_V1_BankSwapper.asm"
	;read "..\SrcMSX\MSX_V1_GetHardwareVer.asm"
	
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

		read "..\SrcALL\Multiplatform_BitmapFonts.asm"
		read "..\SrcALL\V1_BitmapMemory.asm"
	endif
	align16

	read "..\SrcAll\Multiplatform_ReadJoystick.asm"
	
	read "..\SrcAll\V1_Palette.asm"
	read "..\SrcALL\V2_Functions.asm"
	read "..\SrcALL\V1_Footer.asm"
	;We can use these to make some fake banks for testing cartridges or similar
	ifdef BuildMSX
	ds 16384,254
	ds 16384,253
	ds 16384,252
	ds 16384,251
	ds 16384,250
	endif
	ifdef BuildCONSOLE
	ds 16384,254
	ds 16384,253
	ds 16384,252
	ds 16384,251
	ds 16384,250
	endif