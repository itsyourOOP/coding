GetHardwareVer:		;E=Ram	(0=256k,1=512k)
	di
	ld d,31			;Last bank of 512k machine
	call BankTest
	ld de,&0000
	ret nc
	inc e			;We have 512k
	ret
		
BankTest:
	ld a,Bank0
	call BankSwitch_SetCurrent

	ld a,&69							;Set a test bit in the base bank
	ld (BankBase),a

	ld a,d
	call BankSwitch_SetCurrent			;Switch in the alternate bank
	ld hl,BankBase
	ld a,(hl)
	cpl 								;Flip the bits at the address
	ld (hl),a
	cp (hl)
	jr nz,BankFail

	ld a,Bank0
	call BankSwitch_SetCurrent			;Switch the first bank back
	
	ld a,(BankBase)
	cp &69								;If the bits have changed the alternate bank exists
	jr nz,BankFail
		
	ld a,Bank0
	call BankSwitch_SetCurrent
	scf
	ret
BankFail:
	or a
	ret

