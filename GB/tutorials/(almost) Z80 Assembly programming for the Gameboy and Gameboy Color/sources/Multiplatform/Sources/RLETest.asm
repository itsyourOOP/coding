	nolist

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
	ifdef BuildMSX
BuildMSX_MSXVDP equ 1
		read "..\SrcALL\V1_VdpMemory_Header.asm"
	else
		read "..\SrcALL\V1_BitmapMemory_Header.asm"
	endif

	
	read "..\SrcALL\CPU_Compatability.asm"
	
	read "..\SrcALL\V1_Header.asm"


	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

	Call DOINIT		;Get ready

	;di
	;halt
	
	call ScreenINIT		;Enable the Bitmap Screen

	call monitor

	
;;;;;;;;;;;;;;;; Put some RLE data here ;;;;;;;;;;;;;;;;;	
    
			ld hl,RleFile
		ld de,RleFile_End
		ld bc,RleFile_End-RleFile
		ld ix,0
		ld iy,0
		call VDP_RLEProcessorFromMemory	
		di
		halt
RleFile:	 
		incbin "\ResALL\MSXRle.rle"
RleFile_End:
		include "\SrcMSX\Akuyou_MSX_RLE.asm"
LoadDiscSectorSpecialMSX:;Dummy Label - should never run
		halt	

 
 
 


MonitorRam:
	ds 32
Monitor_TMP1 					equ MonitorRam; &C011
Monitor_NextMonitorPos_2Byte	equ MonitorRam+2;&C012;-13
Monitor_EI_Reenable_2byte 		equ MonitorRam+4;&C014;-5
Monitor_Special					equ MonitorRam+6;&C016
BitmapFont:
	ifdef BMP_UppercaseOnlyFont
		incbin "..\ResALL\Font64.FNT"			;Font bitmap, this is common to all systems
	else
		incbin "..\ResALL\Font96.FNT"			;Font bitmap, this is common to all systems
	endif

	
KeyboardScanner_KeyPresses: ds 16

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UseHardwareKeyMap equ 1 ; Need the Keyboard map

;	read "..\SrcALL\V1_VdpMemory.asm"
	ifdef BuildMSX
		read "..\SrcALL\V1_VdpMemory.asm"
		read "..\SrcALL\V1_HardwareTileArray.asm"
	else
		read "..\SrcALL\Multiplatform_BitmapFonts.asm"
		read "..\SrcALL\V1_BitmapMemory.asm"
	endif
	read "..\SrcALL\Multiplatform_ScanKeys.asm"
	read "..\SrcALL\Multiplatform_KeyboardDriver.asm"
	
	
	read "..\SrcALL\Multiplatform_Monitor_RomVer.asm"
	read "..\SrcALL\Multiplatform_MonitorSimple_RomVer.asm"
	read "..\SrcALL\Multiplatform_ShowHex.asm"
	;read "..\SrcALL\V1_Functions.asm"
	read "..\SrcALL\V2_Functions.asm"
	read "..\SrcALL\V1_Footer.asm"
