Bank0 equ &00
Bank1 equ &01
Bank2 equ &02
Bank3 equ &03
Bank4 equ &04
Bank5 equ &05
Bank6 equ &06
Bank7 equ &07

BankBase equ &4000




RamBank0 equ 1
RamBank1 equ 2
RamBank2 equ 3
RamBank3 equ 4
RamBank4 equ 5
RamBank5 equ 6
RamBankBase equ &D000

GBC_RamBank:			;1=7... 0 does the same as 1
	ld (&FF70),a
	ret
	
GBCart_RamBank:			;Turn on ram bank 0-3 
	push af
		ld b,&0a
		call GBCart_RamBankAlt
	pop af
	ld (&4000),a
	ret	
GBCart_RamBankOff:			;Turn off ram bank
	ld b,0
GBCart_RamBankAlt:
	ld a,&01
	ld (&6000),a
	ld a,b
	ld (&0000),a
	ret
BankSwitch_SetCurrent:				; This allows us to remember 'current' bank
	ld (BankSwitch_CurrentB_Plus1-1),a
	jr BankSwitch


BankSwitch_Reset:
	ld a,0;<-- SP ***
BankSwitch_CurrentB_Plus1:
BankSwitch:
	ld b,a
	xor a
	ld (&6000),a
	ld a,b
	ld (&2000),a
	ret

	
; --------------------------------------------------------------------------------------------
;***************************************************************************************************

;			Firmware Switch

;***************************************************************************************************
;--------------------------------------------------------------------------------------------

Firmware_Kill:	; firmwares? we don't need no steenking firmwares!
Firmware_Restore:	; About that firmware...
	ret






; BankSwitch_RequestVidBank:
	        ; LD HL,BankReqTemp;puffer area
                ; LD (HL),0	;start of the list
; GETS:           rst 6
		; db 24		;get a free segment
                ; RET NZ		;if error then return
                ; LD A,C		;segment number
                ; CP &FC		;<0FCh?, no video segment?
                ; JR NC,ENDGET	;exit cycle if video
                ; INC HL		;next puffer address
                ; LD (HL),C	;store segment number
                ; JR GETS		;get next segment
; ENDGET          PUSH BC		;store segment number
; FREES           LD C,(HL)	;deallocate onwanted

                ; rst 6 
		; db 25		;free non video segments

                ; DEC HL		;previoud puffer address
                ; JR Z,FREES	;continue deallocating
				; ;when call the EXOS 25 function with
				; ;c=0 which is stored at the start of
				; ;list, then got a error, flag is NZ
                ; POP BC		;get back the video segment number
                ; XOR A		;Z = no error

                ; RET		;return
; BankReqTemp:
		; ds 16

