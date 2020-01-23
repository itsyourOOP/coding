;for tutorial content see : http://www.chibiakumas.com/z80/platform3.php#LessonP27


Bank0 equ &FF
Bank1 equ &FE
Bank2 equ &FC
Bank3 equ &FD
Bank4 equ &FB
Bank5 equ &FA
Bank6 equ &F9
Bank7 equ &F8

BankBase equ &4000




; --------------------------------------------------------------------------------------------
;***************************************************************************************************

;			Bank Call - Call a location in a different bank then return

;***************************************************************************************************
;--------------------------------------------------------------------------------------------
CallDE
	push de
	ret
CallHL:			
	push hl
	ret





BankSwitch_CallHL:
	push af
		ld a,(BankSwitch_CurrentB_Plus1-1)
		ld (BankSwitch_CallHL_InterruptSafe_MemRestore_Plus1-1),a
	pop af

	call BankSwitch_SetCurrent	; switch to bank A
BankSwitch_CallHLDirect:
	call CallHL
	ld a,0;<-- SP ***
BankSwitch_CallHL_InterruptSafe_MemRestore_Plus1:
	jr BankSwitch_SetCurrent ; Restore the previous bank

;	jr BankSwitch_Reset ; Restore the previous bank
BankSwitch_SetCurrentToC0:
	ld a,(BankDefault1)
BankSwitch_SetCurrent:				; This allows us to remember 'current' bank

	ld (BankSwitch_CurrentB_Plus1-1),a
	OUT (&B1),A ;Send it
	ret

BankSwitch_BankCopy:
	push bc
		call BankSwitch
	pop bc
	ldir
;	jr BankSwitch_128k_Reset ; Restore the previous bank
BankSwitch_Reset:
	ld a,0;<-- SP ***
BankSwitch_CurrentB_Plus1:
BankSwitch:

	OUT (&B1),A ;Send it
	ret

	;&B0 - Ram page 0 (0000-4000)
	;&B1 - Ram page 1 (4000-8000)
	;&B2 - Ram page 2 (8000-C000)
	;&B3 - Ram page 3 (C000-FFFF)
BankDefaults:
BankDefault0: db &F8
BankDefault1: db &F8
BankDefault2: db &F8
BankDefault3: db &F8

BankFirmware0: db &F8
BankFirmware3: db &00
; --------------------------------------------------------------------------------------------
;***************************************************************************************************

;			Firmware Switch

;***************************************************************************************************
;--------------------------------------------------------------------------------------------

Firmware_Kill:	; firmwares? we don't need no steenking firmwares!

	di

	ld a,(BankDefault0)
	ld (&B0),a

	ld a,(BankDefault1)
	ld (&B1),a

	ld a,(BankDefault2)
	ld (&B2),a

	ld a,(BankDefault3)
	ld (&B3),a

	ret


Firmware_Restore:	; About that firmware...
	

	ret

BankSwitch_RequestBank:
	rst 6*8	;Segment please!
	db 24
	ret



; 11.22 Function 24 - Allocate Segment 
    ; Parameters :    none
    ; Results    :  A status
                  ; C segment number
                 ; DE EXOS boundary within this segment
; The allocate segment function allows the user to obtain another 16K segment for his use. If a free segment is available then it will be allocated and status returned zero with the segment number in C and DE will be 4000h. 

; If there are no free segments but the user can be allocated a shared segment, then the segment number will be returned in C and DE will be the initial EXOS boundary. In this case a .SHARE error will be returned. The user boundary is initially set equal to the EXOS boundary. 

; If there are no free segments and there is already a shared segment then a .NOSEG error will be returned. 

; If this function call is made by a device driver then the segment will be marked as allocated to a device and a shared segment cannot be allocated. 





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

