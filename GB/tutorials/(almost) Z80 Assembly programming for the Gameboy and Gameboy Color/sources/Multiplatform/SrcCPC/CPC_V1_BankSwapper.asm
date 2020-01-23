Bank0 equ &C0		;Bank numbers - platform specific
Bank1 equ &C4
Bank2 equ &C5
Bank3 equ &C6
Bank4 equ &C7
Bank5 equ &CC
Bank6 equ &CD
Bank7 equ &CE
Bank8 equ &CF
BankBase equ &4000	;Memory address of swappable area



BankSwitch_DefaultMem:
	ld a,&C0
BankSwitch_SetCurrent:				; This allows us to remember 'current' bank

	LD B,&7F 						;Gate array port
	ld (BankSwitch_CurrentB_Plus2-2),a
	OUT (C),A 						;Send it
	ret

BankSwitch_BankCopy:
	push bc
		call BankSwitch_Set
	pop bc
	ldir

BankSwitch_Reset:					  ;Reset restores the bank set by set current
	ld a,(BankSwitch_CurrentB_Plus2-2);The idea is that if an alternate bank is needed breifly, interrupts will be disabled, 
BankSwitch_Set:						  ;SET will be used to switch the bank, work will be done, and RESET will put everything back, 
									;then interrupts can be re-enabled

	LD B,&7F 						;Gate array port
	OUT (C),A 						;Send it
	ret

	db &C0,00 ;<--SM ***
BankSwitch_CurrentB_Plus2:			


DoRestoreJumpBlock:					;This will restore the CPC jumpblock
	rst 8
	defw &08bd ;<--SM ***
FirmJumpLoc_Plus2:                  ;initialise firmware jumpblock entries
DoRestoreJumpBlockEnd:
DoRestoreLowJumpBlock:
	exx
	ld bc,&7f00+%10001000+1  ;initialise lower rom and select mode
	out (c),c                   ;this routine must be located above &4000
	xor a
	exx
	ex af,af'
	call &0044                  		;initialise lower jumpblock (&0000-&0040)
	Call &F7D0;DoRestoreJumpBlock
	call &bb00 ; km_initialise          ;initialise keyboard manager
	call &b909 ;kl_l_rom_disable       	;disable lower rom
	ld de,&A500							; first usable byte of memory
	ld hl,&b0ff							; last usable byte of memory
	call &bccb							 ; KL_ROM_WALK
	call &b909 ;kl_l_rom_disable       ;disable lower rom

	ret
DoRestoreLowJumpBlockEnd:            ;and high kernal jumpblock (&b800-&bae4)



Firmware_Restore:	; This will restore the memory area  at &A500-BFFF if it has been wiped (Chibiakumas uses it for screenbuffer 2)
	di	
	ld hl,&A500
	ld de,&A501
	ld bc,&BFD0 -&A501
	xor a
	ld (hl),a
	ldir

	ld hl,DoRestoreLowJumpBlock
	ld de,&FFD0
	ld bc,DoRestoreLowJumpBlockEnd-DoRestoreLowJumpBlock
	ldir
	ld hl,DoRestoreJumpBlock
	ld de,&F7D0
	ld bc,DoRestoreJumpBlockEnd-DoRestoreJumpBlock
	ldir
	call &FFD0


	call &BCB6 ;sound hold
	ei

	;restore Disk operating system Vars here - Please add your own
	;if you have special requirements
	ld hl,&0000;<--SM ***
ParadosSettings_Plus2:
	ld (&BAFE),hl
	ld a,0;<--SM ***
FirwareRestoreDriveNo_Plus1:
	ld hl,(&be7d)	; get address where current drive number is held
	ld (hl),a	; set drive number to previous value

	ret
	
	
	
CpcPlus_BankEnable:	
	ld bc,&7fb8	;Page in PLUS registers	(alt rambank at &4000-&7FFF)
	out (c),c				
	ret

CpcPlus_BankDisable:
	ld bc,&7fa0	;Page out PLUS registers
	out (c),c
	ret

	
BankSwapper_SetCartBank:	;Page bank A in at &C000-&FFFF
	add 128		;Values >128 written to &DF select high cart rom bank... 
	ld b,&DF	;values 0 or 7 would select basic rom or disk rom
	ld c,a
	out (c),c
		
	ld b,&7F ;We've selected the rom, we need to page it with the gate array
	ifdef ScrColor16
		ld c,%10000100	;OO-IULMM	
	else;OOO 4=set rom/mode  I=interrutps  U=Upper rom, L=Lower Rom  MM=mode
		ld c,%10000101	;OO-IULMM
	endif
	out (c),c
	
	ret					;We now have the bank at &C000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetHardwareVer_CpcPlus_Init:			;Turn on the CPC plus
	di
	ld b,&bc
	ld hl,GetHardwareVer_PlusInitSequence
	ld e,17
PlusInitLoop:							;Send the Plus init sequence to 
	ld a,(hl)
	out (c),a
	inc hl
	dec e
	jr nz,PlusInitLoop
	ei
	ret


GetHardwareVer_PlusInitSequence:	;This is a special sequence to unock the CPC+ Asic... it's intentionally random!
	defb &ff,&00,&ff,&77,&b3,&51,&a8,&d4,&62,&39,&9c,&46,&2b,&15,&8a,&cd,&ee


