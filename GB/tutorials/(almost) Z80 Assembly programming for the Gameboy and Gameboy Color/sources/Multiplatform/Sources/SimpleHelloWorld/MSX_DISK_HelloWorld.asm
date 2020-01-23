PrintChar equ &00A2

	;Unrem this if building with vasm
	include "\SrcALL\VasmBuildCompat.asm"

;For Cartridge	
	;org &4000				;Base Cart Address
	;db "AB"					;Fixed Header
	;dw ProgramStart 		;Pointer to start of program
	;db 00,00,00,00,00,00	;Unused

	
	;;;Effectively Code starts at address &400A

;For Disk
	org &810A
	
	

;Common	
ProgramStart:			;Program Code Starts Here

	call &006F			;INIT32 - initialises the screen to GRAPHIC1 mode (32x24)
	
	ld a,32				;Set Screen width to 32 chars
	ld (&F3B0),a		;LINLEN 
	
	
	ld hl,Message		;Address of string
	Call PrintString	;Show String to screen
	
	ret				;Can use RET on disk to return to basic
	
	;DI					;Can't RET on Cartridge
	;Halt 	

	
	
	
NewLine:
	push af
		ld a,13			;Carriage return
		call PrintChar
		ld a,10			;Line Feed
		call PrintChar
	pop af
	ret
	
PrintString:
	ld a,(hl)			;Print a '255' terminated string 
	cp 255
	ret z
	inc hl
	call PrintChar
	jr PrintString

Message: db 'Hello World 323!',255


