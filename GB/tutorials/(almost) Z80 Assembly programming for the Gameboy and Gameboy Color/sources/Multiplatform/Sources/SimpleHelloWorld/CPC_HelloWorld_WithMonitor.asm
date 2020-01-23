	;Unrem this if building with vasm
;	include "\SrcALL\VasmBuildCompat.asm"

PrintChar 	equ &BB5A	

	org &1200

	ld hl,Message			;Address of string
	Call PrintString		;Show String to screen

	call Monitor			;Show Register contents
	
	call newline
	
	ld hl,&0000			;Address to show
	ld c,32				;Bytes to show
	call Monitor_MemDumpDirect	;Show memory to screen

	ret

PrintString:
	ld a,(hl)	;Print a '255' terminated string 
	cp 255
	ret z
	inc hl
	call PrintChar
	jr PrintString

Message: db 'Hello World 323!',255

NewLine:
	ld a,13		;Carriage return
	call PrintChar
	ld a,10		;Line Feed 
	jp PrintChar


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Bonus! Monitor/Memdump

;These are needed only for the Monitor/Memdump

BuildCPC equ 1		
SimpleBuild equ 1
	read "\SrcALL\Multiplatform_Monitor_RomVer.asm"
	read "\SrcALL\Multiplatform_ShowHex.asm"
	read "\SrcALL\Multiplatform_MonitorMemdump.asm"
	