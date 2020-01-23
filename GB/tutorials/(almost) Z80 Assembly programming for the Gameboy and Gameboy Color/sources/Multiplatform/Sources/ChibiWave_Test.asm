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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef vasm
		include "..\SrcALL\VasmBuildCompat.asm"
	else
		read "..\SrcALL\WinApeBuildCompat.asm"
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	read "..\SrcALL\CPU_Compatability.asm"
	read "..\SrcALL\V1_Header.asm"
	ifdef BuildMSX
	;	read "..\SrcALL\V1_BitmapMemory_Header.asm"
	endif
	ifdef BuildCLX
		read "..\SrcALL\V1_BitmapMemory_Header.asm"
	endif
	read "..\SrcALL\V1_VdpMemory_Header.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	Call DOINIT	; Get ready

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Again:	

;samplehello equ 1

bits4 equ 1
;bits2 equ 1
;bits1 equ 1

;freq1 equ 1	;44100 - 1 bit only!
freq2 equ 1	;22050
;freq4 equ 1	;11025
;freq8 equ 1	;5512
;freq16 equ 1	;2480

	ifdef bits4
bitsetting equ 2
		ifdef freq2	
playspeed equ 1
		endif
		ifdef freq4
playspeed equ 10
		endif
		ifdef freq8
playspeed equ 35
		endif
		ifdef freq16
playspeed equ 70
		endif
	endif
	

	ifdef bits2
bitsetting equ 1
		ifdef freq2	
playspeed equ 1
		endif
		ifdef freq4
playspeed equ 12
		endif
		ifdef freq8
playspeed equ 40
		endif
		ifdef freq16
playspeed equ 90
		endif
	endif

	ifdef bits1
bitsetting equ 0
	ifdef freq1
playspeed equ 1
		endif
		ifdef freq2	
playspeed equ 3
		endif
		ifdef freq4
playspeed equ 15
		endif
		ifdef freq8
playspeed equ 40
		endif
		ifdef freq16
playspeed equ 80
		endif
	endif
	
	
	
	ld de,wavedataEnd-wavedata
	ld hl,wavedata
	
	
	ld a,bitsetting	;BitsPerSample (0/1/2= 1/2/4)
	ld b,playspeed	; scaledown 
	ifdef BuildGBC
		srl b
	endif
	ifdef BuildZXS
		;sll b
	endif
	di
	call ChibiWave
	
	ld bc,&10000
Pauseagain:
	dec bc
	ld a,b
	or c
	jr nz,Pauseagain
	
	jp Again
	
	read "..\SrcALL\V1_BitmapMemory.asm"
	read "..\SrcALL\Multiplatform_ChibiSound.asm"
	read "..\SrcALL\Multiplatform_ChibiWave.asm"
	ifndef BuildMSX
		read "..\SrcALL\V1_VdpMemory.asm"
	endif
	
	
	;read "..\SrcALL\Multiplatform_ShowHex.asm"
BitmapFont:
	ifdef BMP_UppercaseOnlyFont
		;incbin "..\ResALL\Font64.FNT"			;Font bitmap, this is common to all systems
	else
		;incbin "..\ResALL\Font96.FNT"			;Font bitmap, this is common to all systems
	endif
wavedata:
;	incbin "\ResALL\Wave\helllo1-2.raw"		;1bit - freq 2	
	;incbin "\ResALL\Wave\hello2-2.raw"		;2bit - freq 2
	;incbin "\ResALL\Wave\helloB2-2.raw"		;2bit - freq 2
	;incbin "\ResALL\Wave\hello2-2.raw"		;2bit - freq 2
	
	ifdef samplehello
			ifdef bits4
				ifdef freq2
					incbin "\ResALL\Wave\hello4-2.raw"
				endif
				ifdef freq4
					incbin "\ResALL\Wave\hello4-4.raw"
				endif
				ifdef freq8
					incbin "\ResALL\Wave\hello4-8.raw"
				endif
				ifdef freq16
					incbin "\ResALL\Wave\hello4-16.raw"
				endif
			endif
			ifdef bits2
				ifdef freq2
					incbin "\ResALL\Wave\hello2-2.raw"
				endif
				ifdef freq4
					incbin "\ResALL\Wave\hello2-4.raw"
				endif
				ifdef freq8
					incbin "\ResALL\Wave\hello2-8.raw"
				endif
				ifdef freq16
					incbin "\ResALL\Wave\hello2-16.raw"
				endif
			endif
			ifdef bits1
			ifdef freq1
					incbin "\ResALL\Wave\hello1-1.raw"
				endif
				ifdef freq2
					incbin "\ResALL\Wave\hello1-2.raw"
				endif
				ifdef freq4
					incbin "\ResALL\Wave\hello1-4.raw"
				endif
				ifdef freq8
					incbin "\ResALL\Wave\hello1-8.raw"
				endif
				ifdef freq16
					incbin "\ResALL\Wave\hello1-16.raw"
				endif
			endif
	else
			ifdef bits4
				ifdef freq2
					incbin "\ResALL\Wave\bestsamples4-2.raw"
				endif
				ifdef freq4
					incbin "\ResALL\Wave\bestsamples4-4.raw"
				endif
				ifdef freq8
					incbin "\ResALL\Wave\bestsamples4-8.raw"
				endif
				ifdef freq16
					incbin "\ResALL\Wave\bestsamples4-16.raw"
				endif
			endif
			ifdef bits2
				ifdef freq2
					incbin "\ResALL\Wave\bestsamples2-2.raw"
				endif
				ifdef freq4
					incbin "\ResALL\Wave\bestsamples2-4.raw"
				endif
				ifdef freq8
					incbin "\ResALL\Wave\bestsamples2-8.raw"
				endif 
				ifdef freq16
					incbin "\ResALL\Wave\bestsamples2-16.raw"
				endif
			endif
			ifdef bits1
				ifdef freq2
					incbin "\ResALL\Wave\bestsamples1-2.raw"
				endif
				ifdef freq4
					incbin "\ResALL\Wave\bestsamples1-4.raw"
				endif
				ifdef freq8
					incbin "\ResALL\Wave\bestsamples1-8.raw"
				endif 
				ifdef freq16
					incbin "\ResALL\Wave\bestsamples1-16.raw"
				endif
			endif		
			;incbin "\ResALL\Wave\hello4-8.raw"
			;incbin "\ResALL\Wave\hello4-16.raw"
		
	endif
	;incbin "\ResALL\Wave\helloB4-4.raw"
	;incbin "\ResALL\Wave\hello2-8.raw"
	;incbin "\ResALL\Wave\helloB2-8.raw"

	;incbin "\ResALL\Wave\hello2-4.raw"
	;incbin "\ResALL\Wave\hello1-2.raw"
	
	;incbin "\ResALL\Wave\hello1-16.raw"

;	incbin "\ResALL\Wave\bestsamples2-64.raw"	

	;incbin "\ResALL\Wave\bestsamples4-64.raw" ;4 bit - freq 1/64
	;incbin "\ResALL\Wave\bestsamples4-32.raw" ;4 bit - freq 1/32
	;incbin "\ResALL\Wave\bestsamples4-16.raw" ;4 bit - freq 1/16
	;incbin "\ResALL\Wave\bestsamples4-8.raw"  ;4 bit - freq 1/8
	;incbin "\ResALL\Wave\bestsamplesB4-8.raw"  ;4 bit - freq 1/8
	;incbin "\ResALL\Wave\bestsamplesB4-4.raw"  ;4 bit - freq 1/4
	;incbin "\ResALL\Wave\bestsamples4-4.raw"  ;4 bit - freq 1/4
	
	;incbin "\ResALL\Wave\bestsamples4-3.raw"  ;4 bit - freq 1/3
	;incbin "\ResALL\Wave\bestsamples4-2.raw"  ;4 bit - freq 1/2
	
	;incbin "\ResALL\Wave\bestsamples4-64.raw" ;4 bit - freq 1/64
	;incbin "\ResALL\Wave\bestsamples4-32.raw" ;4 bit - freq 1/32
	;incbin "\ResALL\Wave\bestsamples4-16.raw" ;4 bit - freq 1/16
	;incbin "\ResALL\Wave\bestsamples4-8.raw"  ;4 bit - freq 1/8
	;incbin "\ResALL\Wave\bestsamples4-4.raw"  ;4 bit - freq 1/4
	;incbin "\ResALL\Wave\bestsamples4-3.raw"  ;4 bit - freq 1/3
	;incbin "\ResALL\Wave\bestsamples4-2.raw"  ;4 bit - freq 1/2
	
	
wavedataEnd:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	read "..\SrcALL\V1_Functions.asm"
	read "..\SrcALL\V1_Footer.asm"
