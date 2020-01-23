TestSprite equ &C010
Monitor_TMP1 equ &C011

Monitor_NextMonitorPos_2Byte equ &C012;-13
Monitor_EI_Reenable_2byte equ &C014;-5
Monitor_Special	equ &C016

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

BuildSMS_BuildQuick equ 1

Monitor_Full equ 1
Monitor_Pause equ 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef vasm
		include "..\SrcALL\VasmBuildCompat.asm"
	else
		read "..\SrcALL\WinApeBuildCompat.asm"
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	


;read "..\SrcALL\V1_Header.asm"
	read "..\SrcALL\V1_Header.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	Call DOINIT	; Get ready

	call Cls
	; LCCTXXXX
	
	; L - Top bit is the 'Latch bit' - 1 = new command 0= more settings
	; C - Channel 0-4 (0-3 = Tone) (4=Noise)
	; T - Type... 0 = Set Tone/Freq ... 1 = set Volume
	
	; Tone Channels XXXX
	; LLLL = Tone 
	
	; Noise Channel XXXX
	; -MRR = Noise Mode & Rate (11=use tone 2)
	
	; Volume Type XXXX
	; VVVV = Volume (0=max)

	;Tone Channels take a second byte (where latch L=0)
	
		; 1CCTLLLL
	ld a,%11001111	;(Latch - Channel Type - Tone Data L)
	out (&7F),a
	
		 ;0-HHHHHH
	ld a,%00000001	;(Latch off - Tone Data H)
	out (&7F),a
	
		 ;1CCTVVVV
	ld a,%11011111	;(Latch - Channel Type Volume)	
	out (&7F),a

		 ;1CCT-MRR
	ld a,%11100111	;(Latch - Channel Type... 
	out (&7F),a		;noise Mode (1=white) Rate 
					;(Rate 11= use Tone Channel 2)
	
		 ;1CCTVVVV
	ld a,%11110000	;(Latch - Channel Type Volume)	
	out (&7F),a

	di
	halt

;read "..\SrcAll\Multiplatform_MonitorMemdump.asm"
;read "..\SrcAll\Multiplatform_MonitorSimple_RomVer.asm"
;read "..\SrcAll\Multiplatform_ShowHex.asm"
;read "..\SrcAll\Multiplatform_Monitor_Romver.asm"
BitmapFont:
	ifdef BMP_UppercaseOnlyFont
		incbin "..\ResALL\Font64.FNT"			;Font bitmap, this is common to all systems
	else
		incbin "..\ResALL\Font96.FNT"			;Font bitmap, this is common to all systems
	endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	read "..\SrcALL\V1_VdpMemory.asm"
	read "..\SrcALL\V1_Functions.asm"
	read "..\SrcALL\V1_Footer.asm"