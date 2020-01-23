	org &6500	
	xor a					;By default lynx makes a noise
	out (%10000100),a		;so we mute the noise here!
	
	ld hl,Message			;Address of string
	Call PrintString		;Show String to screen

	ret 					;return to basic
	
NewLine:
	ld a,13					;Carriage return
	jp PrintChar

PrintChar:
	rst 8
	ret
	
PrintString:
	ld a,(hl)				;Print a '255' terminated string 
	cp 255
	ret z
	inc hl
	call PrintChar
	jr PrintString

Message: db 'Hello World 323!',255
		
