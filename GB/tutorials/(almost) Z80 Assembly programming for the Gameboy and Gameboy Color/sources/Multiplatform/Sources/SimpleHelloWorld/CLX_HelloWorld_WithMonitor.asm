	include "\SrcALL\VasmBuildCompat.asm"
	
	org &7000	
	xor a					;By default lynx makes a noise
	out (%10000100),a		;so we mute the noise here!
	
	ld hl,Message			;Address of string
	Call PrintString		;Show String to screen

	call Monitor			;Show Register contents
	call newline
	
	ld hl,&7000				;Address to show
	ld c,32					;Bytes to show
	call Monitor_MemDumpDirect	;Show memory to screen

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
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Bonus! Monitor/Memdump

;These are needed only for the Monitor/Memdump

;BuildCLX equ 1		
SimpleBuild equ 1
	read "\SrcALL\Multiplatform_Monitor_RomVer.asm"
	read "\SrcALL\Multiplatform_ShowHex.asm"
	read "\SrcALL\Multiplatform_MonitorMemdump.asm"
	
	