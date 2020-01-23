
;	D=SpeccyVer	(1=+3)
;	E=Ram		(0=48k,1=128k)
	

GetHardwareVer:		
	di
	ld de,&0000
		
	push de
		ld d,Bank7
		call BankTest
	pop de
	ret nc
	inc e	;If we've got 128k set E=1
;;;;;;;;;;;;;;;;;;;;;;;; Test for +3
	push de
		ld a,(&5B5C)	;+3 memory mode won't allow access to this bank
		ld e,a
		ld a,(&5B67)
		ld d,a
			;---SDR-P		P = paging mode 1=+3
		and %11111000
		or  %00000001	;We're going to page in +3 
	;Option 00 = Bank 0/1/2/3 - this will make the stack and screen inaccessible
		
		ld bc,&1FFD
		out (c),a
		
		ld a,e
		and  %11111000	;Page in Bank 0 on the regular 128
		ld bc,&7FFD
		out (c),a
		
		ld a,(BankBase) ;Flip the bits of &C000 
		cpl 			;this will affect Bank 0 on a 128, or bank 3 on a +3
		ld (BankBase),a
		
		ld a,d			;Reset banking!
		ld bc,&1FFD
		out (c),a
		
		ld a,e			;Reset banking!
		ld bc,&7FFD
		out (c),a
		
	pop de
	
	ld a,(BankBase) ; Read back - if it's &69 - we're on a+3
	cp &69
	ret nz
	inc d 	;We've go a +3
	
	
	ret
	
BankTest:
	ld a,Bank0
	call BankSwitch_SetCurrent

	ld a,&69	; set &69 as a marker that we can look for later
	ld (BankBase),a

	ld a,d
	call BankSwitch_SetCurrent
	
	ld a,(BankBase)		;Flip the bits - if we have no extra banks,
	cpl 				; our marker will be altered 
	ld (BankBase),a
	
	ld a,Bank0					;Reset the default bank
	call BankSwitch_SetCurrent
	
	ld a,(BankBase)
	cp &69						;See if our makeer is OK
	jr nz,BankFail	
	
	ld a,Bank0
	call BankSwitch_SetCurrent
	scf							;Set carry = bank worked
	ret
BankFail:
	or a						;Reset carry = Bank didn't work
	ret

