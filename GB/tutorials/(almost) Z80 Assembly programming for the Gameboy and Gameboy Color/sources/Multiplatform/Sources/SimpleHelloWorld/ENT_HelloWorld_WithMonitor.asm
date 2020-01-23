	include "\SrcALL\VasmBuildCompat.asm"

	ORG &00F0
	
	DB 0,5			;type 5 = machine code application program
	DW FileEnd-FileStart	;16 bit lenght
	DB 0,0,0,0,0,0,0,0,0,0,0,0 ;not used bytes

FileStart:	;Program starts at &100
	LD SP,&100	

	
	ld de,ENT_Screenname
	ld a,10	;Open Screen as stream 10
	rst 48	;RST 6 - EXOS Call
	db 1 	;Open stream A from device string DE 
		;DE should point to a string like...  db 6,'VIDEO:'  or db 9,'KEYBOARD:'

	ld a,10	; A channel number (1..255)
	ld b,1	; B @@DISP (=1) (special function code)
	ld c,1	; C 1st row in page to display (1..size)
	ld d,24 ; D number of rows to display (1..27)
	ld e,1  ; E row on screen where first row should appear (1..27)
	rst 48	;RST 6 - EXOS Call
	db 11	;Special Function (for displaying screen)
	
	
	
	
	
	
	
	
	
	
	

	ld hl,Message			;Address of string
	Call PrintString		;Show String to screen

	call Monitor			;Show Register contents
	
	call newline
	
	ld hl,&0100			;Address to show
	ld c,32				;Bytes to show
	call Monitor_MemDumpDirect	;Show memory to screen

	di		;Stop CPU
	halt
	

NewLine:
	ld a,13		;Carriage return
	call PrintChar
	ld a,10		;Line Feed 
	jp PrintChar

PrintChar:
	push af
	push de
	push bc
		ld b,a
		ld a,10 ;Screen is channel 10
		rst 48
		db 7 	;write to channel a
	pop bc
	pop de
	pop af
	ret
	

PrintString:
	ld a,(hl)	;Print a '255' terminated string 
	cp 255
	ret z
	inc hl
	call PrintChar
	jr PrintString

Message: db 'Hello World 323!',255

ENT_Screenname: db 6,'VIDEO:'		;Stream name for screen
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Bonus! Monitor/Memdump

;These are needed only for the Monitor/Memdump

;BuildENT equ 1		
SimpleBuild equ 1
	read "\SrcALL\Multiplatform_Monitor_RomVer.asm"
	read "\SrcALL\Multiplatform_ShowHex.asm"
	read "\SrcALL\Multiplatform_MonitorMemdump.asm"
	
	
FileEnd:
	