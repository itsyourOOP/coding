		;Unrem this if building with vasm
	include "\SrcALL\VasmBuildCompat.asm"

	Org &8000				;Code Origin

	ld hl,Message			;Address of string
	Call PrintString		;Show String to screen
	
	
	call Monitor			;Show Register contents
	
	call newline
	
	ld hl,&8000					;Address to show
	ld c,32						;Bytes to show
	call Monitor_MemDumpDirect	;Show memory to screen

	
	;di
	;halt			;Stop processor so we can see result
	
	ret				;Return to basic
	
NewLine:
	ld a,13			;Carriage return
	jr PrintChar
	
	
PrintChar:
	push hl
	push bc
	push de			
	push af
		rst 16		;call &0010	- Print Accumulator character to screen
	pop af
	pop de
	pop bc			
	pop hl
	ret	

PrintString:
	ld a,(hl)		;Print a '255' terminated string 
	cp 255
	ret z
	inc hl
	call PrintChar
	jr PrintString

Message: db 'Hello World 323!',255



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Bonus! Monitor/Memdump

;These are needed only for the Monitor/Memdump

;BuildSAM equ 1		;Enable this if you don't use my scripts
SimpleBuild equ 1
	read "\SrcALL\Multiplatform_Monitor_RomVer.asm"
	read "\SrcALL\Multiplatform_ShowHex.asm"
	read "\SrcALL\Multiplatform_MonitorMemdump.asm"
	