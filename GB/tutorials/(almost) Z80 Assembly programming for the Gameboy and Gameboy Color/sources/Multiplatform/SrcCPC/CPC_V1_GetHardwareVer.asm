GetHardwareVer:		
;	D=CPCVer	(1=Plus)
;	E=Ram		(0=64k,1=128k,2=256k)
		
	ld de,&0000
	
	push de
			call GetHardwareVer_CpcPlus_Init
			call PlusTest
	pop de
	jr nc,GetHardwareVer_NoPlus
	inc d					;Store 1 in D if PLUS
GetHardwareVer_NoPlus:		
	push de
		ld d,Bank4			;Try to use bank 4 (exists on 128k+)
		call BankTest
	pop de
	ret nc
	inc e
	push de
		ld d,Bank8			;Try to use bank 8 (exists on 256k+)
		call BankTestExt
	pop de
	ret nc
	inc e

	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BankTest:
	ld a,Bank0					;Turn Bank 0 on (Base 64k)
	call BankSwitch_SetCurrent

	ld a,&69					;Store a byte in the base bank
	ld (BankBase),a

	ld a,d
	call BankSwitch_SetCurrent	;Try to turn on the extra bank
	
	ld a,(BankBase)				;alter the bye at the same location
	cpl 
	ld (BankBase),a
	
	ld a,Bank0					;Turn off the Extra bank
	call BankSwitch_SetCurrent
	
	ld a,(BankBase)				;Is the byte we wrote first still there
	cp &69
	jr nz,BankFail				;If it IS, then we must have extra ram!
	scf
	ret
BankFail:
	or a
	ret
	
	
BankTestExt:						;on a 128K - trying to turn on the 256k bank will actually turn on the matching 128k bank
	ld a,d							;NOT do nothing like on 64k systems Therefore we cannot use the code above
	and %11000111
	call BankSwitch_SetCurrent		;Turn on matching 128k bank

	ld a,&69						;Set the marker bit
	ld (BankBase),a

	ld a,d
	call BankSwitch_SetCurrent		;Turn on the bank we want to test
	
	ld a,(BankBase)					;Flip the bits
	cpl 			
	ld (BankBase),a
	
	ld a,d
	and %11000111					;Turn on the first bank again
	call BankSwitch_SetCurrent
	
	ld a,(BankBase)					;Is the byte we wrote first still there
	cp &69
	jr nz,BankFail					;If it IS, then we must have extra ram!
	
	
	ld a,Bank0
	call BankSwitch_SetCurrent		;Turn off bank switching
	scf
	ret	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
PlusTest:
	ld a,Bank0						;Set Bank 0 at &4000
	call BankSwitch_SetCurrent
	
	
	ld a,&69
	ld (BankBase),a					;Store a byte at that address

	call CpcPlus_BankEnable			;Turn on the Plus bank (this will do nothing on a non plus)
	
	ld a,(BankBase)					;Read in the data from that address
	cpl 							;Alter it
	ld (BankBase),a					;Save it back
	
	call CpcPlus_BankDisable		;Turn off the plus bank
	
	ld a,(BankBase)					;See if the data is still in the non plus bank
	cp &69							;If it ISNT then turning on the plus bank didn't work
	jr nz,PlusFail
		
	scf								;Set Carry flag
	ret
PlusFail:
	or a							;Clear Carry flag
	ret
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;