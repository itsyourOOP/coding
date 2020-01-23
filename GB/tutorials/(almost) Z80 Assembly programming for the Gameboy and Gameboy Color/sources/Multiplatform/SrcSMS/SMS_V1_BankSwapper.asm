Bank0 equ &00
Bank1 equ &01
Bank2 equ &02
Bank3 equ &03
Bank4 equ &04
Bank5 equ &05
Bank6 equ &06
Bank7 equ &07

RamBankOff equ 0
RamBank0 equ %00001000
RamBank1 equ %00001100
RamBankBase equ &8000


SMSCartBank:
	ld (&FFFC),a
	ret

BankBase equ &4000

BankSwitch_SetCurrent:				; This allows us to remember 'current' bank
	ld (BankSwitch_CurrentB_Plus1-1),a
	jr BankSwitch


BankSwitch_Reset:
	ld a,0;<-- SP ***
BankSwitch_CurrentB_Plus1:
BankSwitch:
	ld (&FFFE),a
	ret

	
; --------------------------------------------------------------------------------------------
;***************************************************************************************************

;			Firmware Switch

;***************************************************************************************************
;--------------------------------------------------------------------------------------------

Firmware_Kill:	; firmwares? we don't need no steenking firmwares!
Firmware_Restore:	; About that firmware...
	ret

