
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



;read "..\SrcALL\V1_Header.asm"
	read "..\SrcALL\V1_Header.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	Call DOINIT	; Get ready

	call CLS


;&F4xx 0 0 Port A Data Read/Write In/Out PSG (Sound/Keyboard/Joystick)  
;&F5xx 0 1 Port B Data Read/Write In Vsync/Jumpers/PrinterBusy/CasIn/Exp  
;&F6xx 1 0 Port C Data Read/Write Out KeybRow/CasOut/PSG  
;&F7xx 1 1 Control Write Only Out Control  

;PPI Port C
;Bit 7 	Bit 6 	Function  
;0 	0 	Inactive  
;0 	1 	Read from selected PSG register  
;1 	0 	Write to selected PSG register  
;1 	1 	Select PSG register  


;Tone Generator Control 	R0--R5 	Program tone periods.
;Noise Generator Control 	R6 	Program noise period.
;Mixer Control 			R7 	Enable tone and/or noise on selected channels.
;Amplitude Control 		R10--R12 	Select "fixed" or "envelope-variable" amplitudes.
;Envelope Generator Control 	R13--R15 	Program envelope period and select envelope pattern. 


;	LD B,&F7                ;8255 Control port
;        LD A,%10000010          ;Configuration function
;        OUT (C),A               ;Send to 8255


	di
again:	
	ld a,0		;TTTTTTTT Tone Lower 8 bits	- Channel A
	ld c,%11111111
	call AYRegWrite
	ld a,1		;----TTTT Tone Upper 4 bits
	ld c,%00000000
	call AYRegWrite

	
	; ld a,2	;TTTTTTTT Tone Lower 8 bits	- Channel B
	; ld c,128
	; call AYRegWrite
	; ld a,3	;----TTTT Tone Upper 4 bits
	; ld c,%00000011
	; call AYRegWrite

	
	; ld a,4	;TTTTTTTT Tone Lower 8 bits	- Channel C
	; ld c,128
	; call AYRegWrite
	; ld a,5	;----TTTT Tone Upper 4 bits
	; ld c,%00000011
	; call AYRegWrite

	
	ld a,6		;Noise ---NNNNN
	ld c,%00000011
	call AYRegWrite

	ld a,7		;Mixer  --NNNTTT (1=off) --CBACBA
	ld c,%00111110
	call AYRegWrite


	;*** these are incorrectly marked as Amplitude Control (Registers R10,R11,R12) in some documentation! ***

	ld a,8		;4-bit Volume / Envelope for channel A ---EVVVV
	ld c,%000011111	;E=1 means envelope on
	call AYRegWrite

	ld a,9		;4-bit Volume for channel B ---EVVVV
	ld c,%00001111
	call AYRegWrite

	ld a,10		;4-bit Volume channel C ---EVVVV
	ld c,%00011111
	call AYRegWrite


	 ld a,11		;Envelope Generator Control  Fine
	 ld c,%10000000
	 call AYRegWrite

	 ld a,12		;Envelope Generator Control Coarse
	 ld c,%00000000
	 call AYRegWrite

	 ld a,13	;Envelope
	 ld c,%00001010
	 call AYRegWrite

;	ld bc,&F6C0
;	out (c),c	;#f6c0 11000000

;	di
;	halt

loop:
	jp loop


AYRegWrite:
	ifdef BuildCPC
		push bc
			ld b,&f4
			ld c,a
			out (c),c	;#f4 Regnum (from a)

			ld bc,&F6C0	;Select REG
			out (c),c	

			ld bc,&f600	;Inactive (needed)
			out (c),c

			ld bc,&F680	;Write VALUE
			out (c),c	
		pop bc
		ld b,&F4	;#f4 value (from C)
		out (c),c

		ld bc,&f600	; inactive (needed)
		out (c),c
	endif

	ifdef BuildZXS
		push bc
			ld bc,&FFFD
			out (c),a	;Regnum
		pop bc
			ld a,c
			ld bc,&BFFD
			out (c),a	;Value
	endif

	ifdef BuildMSX
		push bc
			out (#a0),a	;regnum
		pop bc
			ld a,c
			out (#a1),a	;value
	endif
	ret


	









;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	read "..\SrcALL\V1_Functions.asm"
	read "..\SrcALL\V1_Footer.asm"
