	;Unrem this if building with vasm
	include "\SrcALL\VasmBuildCompat.asm"

	Org &8000				;Code Origin

	ld hl,Message			;Address of string
	Call PrintString		;Show String to screen
	
	di
	halt			;Stop processor so we can see result
	
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


