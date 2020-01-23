
	org &9D93
	db &BB,&6d	;Header
	;Program actually starts at 9D95
	
	
	ld hl,Message			;Address of string
	Call PrintString		;Show String to screen

	ret 					;return to basic
	
PrintChar:
	push hl
	push bc
	push de
		rst &28		;BCALL
		dw &4504	;PutC firmware function
	pop de
	pop bc
	pop hl
	ret	
	
NewLine:
	push hl
	push bc
	push de
		rst &28		;BCALL
		dw &452E	;_newline firmware function
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

Message: db 'Hello World 324!',255
		
