
;Uncomment one of the lines below to select your compilation target

;BuildCPC equ 1	; Build for Amstrad CPC
;BuildMSX equ 1 ; Build for MSX
;BuildTI8 equ 1 ; Build for TI-83+
;BuildZXS equ 1 ; Build for ZX Spectrum
;BuildENT equ 1 ; Build for Enterprise
;BuildSAM equ 1 ; Build for SamCoupe
;BuildSMS equ 1 ; Build for Sega Mastersystem
;BuildSGG equ 1 ; Build for Sega GameGear
;;BuildGMB equ 1 ; Build for GameBoy Regular
;BuildGBC equ 1 ; Build for GameBoyColor 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef vasm
		include "..\SrcALL\VasmBuildCompat.asm"
	else
		read "..\SrcALL\WinApeBuildCompat.asm"
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

;read "..\SrcALL\V1_Header.asm"
	include "..\SrcALL\V1_Header.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			Start Your Program Here
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	Call DOINIT	; Get ready
	;call SetGBPaletteLight
;	call SetGBPaletteDark
	
	;call GBC_Turbo
	call Cls	

	
	
	 ld a,%01110111 ;-LLL-RRR Channel volume
	 ld a,(&FF24)
	
	 ld a,%11111111 ;Mixer LLLLRRRR Channel 1-4 L / Chanel 1-4R
	 ld (&FF25),a
	
	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;						Channel 3 - Wave
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	
	; xor a
	; ld b,%11111111
	; ld hl,&FF30		;Wave Pattern Ram	;
	; ldi (hl),a	;1
	; ldi (hl),a	;2
	; ld (hl),b	;8
	; inc hl
	; ldi (hl),a	;4
	; ldi (hl),a	;5
	; ldi (hl),a	;6
	; ldi (hl),a	;7
	; ld (hl),b	;8
	; inc hl
	; ldi (hl),a	;1
	; ldi (hl),a	;2
	; ldi (hl),a	;3
	; ldi (hl),a	;4
	; ld (hl),b	;8
	; inc hl
	; ldi (hl),a	;6
	; ldi (hl),a	;7
	; ld (hl),b	;8
	
	
	
	; ld a,%00100000 ;-VV----- VV=Volume (0=off 1=max 2=50% 3=25%)
	; ld (&FF1C),a
	
	; ld a,0			;Sound Length (0-255) (Higher is shorter -
	; ld (&FF1b),a	;					   no effect unles C=1 in FF1E)				
		
	; ld a,%10000000	;Enable channel E------- 1=on
	; ld (&FF1A),a
	
	; ld a,%11111111  ;LLLLLLLL Low frequency
	; ld (&FF1D),a	
	
	; ld a,%10000011	;RC---HHH	H=high frequency C=counter repeat (loop)
	; ld (&FF1E),a	;				 R=Restart sample
	
	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	;Channel 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	 ; ld a,%01111001	;Channel 1 Sweep register (R/W)
	 ; ld (&FF10),a	;-TTTDNNN	T=Time,D=direction,N=Numberof shifts 
	
	 ; ld a,%11111111
	 ; ld (&FF11),a	;Sound Length

	 ; ld a,%11110000	;%VVVVDNNN C1 Volume / Direction 0=down / envelope Number (fade speed)
	 ; ld (&FF12),a
	
	 ; ld a,64			;%LLLLLLLL pitch L
	 ; ld (&FF13),a
	
	 ; ld a,%10000011	;%IC---HHH	C1 Initial / Counter 1=stop / pitch H
	 ; ld (&FF14),a
	
	
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	;Channel 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	  ; ld a,%00000000	;Wave Duty (Tone) & Sound Length (Higher is shorter 
	  ; ld (&FF16),a	;- no effect unles C=1 in FF1E)
					
	  ; ld a,%00001111	;%VVVVDNNN C1 Volume / Direction 0=down / envelope Number
	  ; ld (&FF17),a	;								(fade speed - higher is slower)
	 
	  ; ld a,255		;%LLLLLLLL pitch L
	  ; ld (&FF18),a
	 
	  ; ld a,%10000110	;%IC---HHH	C1 Initial / Counter 1=stop / pitch H
	  ; ld (&FF19),a
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
	;Channel 4 ;Noise
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
	ld a,%00001111	;%---LLLLL	Length
	ld (&FF20),a
	
	ld a,%11111000  ;%VVVVDNNN C1 Volume / Direction 0=down 
	ld (&FF21),a	;		  / envelope Number (fade speed)
	
	ld a,%00111000	;SSSSCDDD Shift clock frequency (pitch) / 
	ld (&FF22),a	;Counter Step 0=15bit 1=7bit (sounds eletronic)
					;			/ Dividing ratio (roughness)
					
	ld a,%10000000	;%IC------	C1 Initial / Counter 1=stop
	ld (&FF23),a
	
	di
	halt



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			End of Your program
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SetVram:
BitmapFont:
StopLCD:
	ret
	include "..\SrcALL\V1_Functions.asm"
	include "..\SrcALL\V1_Footer.asm"
