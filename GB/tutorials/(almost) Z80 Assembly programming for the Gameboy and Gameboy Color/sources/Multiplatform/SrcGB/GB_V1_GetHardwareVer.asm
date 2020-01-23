GetHardwareVer:		
	di	

	call BankTest
	ld de,&0000
	ret nc
	inc d
	
	ret
	
;	D=GB	(1=Color)
;	E=0
	
BankTest:
	ld a,0		;Page in GBC ram bank (0/1 - they are the same thing!)
	ld (&FF70),a
	ld hl,&D800
	
	ld a,&69
	ld (hl),a

	ld a,2				;Page in CGB ram (2)
	ld (&FF70),a
	
	ld a,(hl)
	cpl 
	ld (hl),a
	
	ld a,0		;Page in GBC ram bank (0/1 - they are the same thing!)
	ld (&FF70),a
	
	ld a,(hl)
	cp &69
	jr nz,BankFail
	
	scf
	ret
BankFail:
	or a
	ret

