Bank0 equ &00
Bank1 equ &01
Bank2 equ &02
Bank3 equ &03
Bank4 equ &04
Bank5 equ &05
Bank6 equ &06
Bank7 equ &07
BankBase equ &C000


out7ffdBak equ &5b5c
out1FFDBak equ &5B67
;*** Ram/Rom bank switching ***

;port	Backup
;&7FFD	&5B5C	--IRSMMM	MMM= ram bits				S=Screen page bit
;							R Rom Low bit 				I=I/O Disabling

;&1FFD	&5B67	---SDR-P	P = paging mode 0=normal	R=Rom high bit
;							D = Disk Motor				S=Printer strobe
;&1FFD		&7FFD								
;-----0--	---0----	ROM 0 128k editor, menu system and self-test program
;-----0--	---1----	ROM 1 128k syntax checker
;-----1--	---0----	ROM 2 +3DOS
;-----1--	---1----	ROM 3 48 BASIC

Firmware_Kill:				; Game mode - Font in memory
	ifdef buildZXS_DSK
		xor a
		ld (Plus3_RestoreBuffer),a	;Mark that we need to restore the +3 Disk ram
	endif

	ld b,&fe
;0xfe	      xxxEMBBB	Ear Mic Border
	ld c,%00010000
	out (c),c

	ld d,%00000100
	ld e,%00010000
	jr Firmware_Apply
Firmware_Restore:			; Disk mode

	ld iy,&5C3A	;Do this - or suffer the concequences! - should always be set when firmware interrupts may run!

	ifdef buildZXS_DSK
		ld d,%00000100
		ld e,0
	endif


	ifdef buildZXS_TRD
		ld d,%00000000			; Rom 1
		ld e,%00010000
	endif
	ifdef buildZXS_TAP
		ld d,%00000100			;NEED ROM 3 on PLUS, 1 on 128k, 0 on 48k
		ld e,%00010000
	endif
	im 1
Firmware_Apply:
	ld a,(out1FFDBak)
	and  %11111011
	or d
        ld   bc,&1ffd   ;32765
        out  (c),a
	ld (out1FFDBak),a
        ld   a,(out7ffdBak)  ;BANKM (23388)
        and  %11101111
	or e
        ld   bc,&7ffd   ;32765
        out  (c),a
        ld   (out7ffdBak),a
	ret








BankSwitch_Init:
        ld   a,(out7ffdBak)  ;BANKM (23388)
        and  %00000111
BankSwitch_SetCurrent:
	ld (BankSwitch_ZXBank_Current_Plus1-1),a
	jp BankSwitch_set
BankSwitch_Reset:
        ld   a,0 ;<-- SM ***
BankSwitch_ZXBank_Current_Plus1:  ;BANKM (23388)
BankSwitch_Set:
        ld   c,a
        ld   a,(out7ffdBak)  ;BANKM (23388)
        and  %11111000
        or   c
        ld   bc,&7ffd   ;32765
        out  (c),a
        ld  (out7ffdBak),a  ;BANKM (23388)
        ret