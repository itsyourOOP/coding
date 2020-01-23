Bank0 equ &00
Bank1 equ &01
Bank2 equ &02
Bank3 equ &03
Bank4 equ &04
Bank5 equ &05
Bank6 equ &06
Bank7 equ &07

BankBase equ &0000

BankSwitch_SetCurrent:	; This allows us to remember 'current' bank
		or %00100000  		;Turn off Rom 0
		ld (BankSwitch_CurrentB_Plus1-1),a
		jr BankSwitch

		BankSwitch_Reset:
		ld a,%00011111;<-- SM ***
BankSwitch_CurrentB_Plus1:
BankSwitch:
		ld bc,250 			;LMPR - Low Memory Page Register 
		OUT (c),A			;Send it
	ret

; --------------------------------------------------------------------------------------------
;***************************************************************************************************

;			Firmware Switch

;***************************************************************************************************
;--------------------------------------------------------------------------------------------

Firmware_Kill:	; firmwares? we don't need no steenking firmwares!
		ld bc,250 	;LMPR - Low Memory Page Register (250 dec) 
		ld a,%00100010  ;Turn off Rom 0
		out (c),a
	ret


Firmware_Restore:	; About that firmware...
		ld bc,250 	;LMPR - Low Memory Page Register (250 dec) 
		ld a,%00000010  ;Turn on Rom 0
		out (c),a
		
	ret
