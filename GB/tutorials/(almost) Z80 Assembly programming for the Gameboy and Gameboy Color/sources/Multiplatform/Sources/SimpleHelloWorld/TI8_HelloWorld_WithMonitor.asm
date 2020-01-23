;Unrem this if building with vasm
	include "\SrcALL\VasmBuildCompat.asm"

	org &9D93
	db &BB,&6d	;Header
	;Program actually starts at 9D95
	
	
	call Monitor				;Show Register contents
	
	ld hl,&8000					;Address to show
	ld c,8						;Bytes to show
	call Monitor_MemDumpDirect	;Show memory to screen

	
	ld hl,Message			;Address of string
	Call PrintString		;Show String to screen

	ret 					;return to basic
	
PrintChar:
	push hl
	push bc
	push de
		rst 40		;BCALL
		dw &4504	;PutC firmware function
	pop de
	pop bc
	pop hl
	ret	
	
NewLine:
	push hl
	push bc
	push de
		rst 40		;BCALL
		dw &452E	;_newline firmware function
	pop de
	pop bc
	pop hl
	ret
	
PrintString:
	ld a,(hl)				;Print a '255' terminated string 
	cp 255
	ret z
	inc hl
	call PrintChar
	jr PrintString

Message: db 'Hello World 323!',255
		



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Bonus! Monitor/Memdump

;These are needed only for the Monitor/Memdump

;BuildTI8 equ 1		;Enable this if you don't use my scripts
SimpleBuild equ 1
	read "\SrcALL\Multiplatform_Monitor_RomVer.asm"
	read "\SrcALL\Multiplatform_ShowHex.asm"
	read "\SrcALL\Multiplatform_MonitorMemdump.asm"
	