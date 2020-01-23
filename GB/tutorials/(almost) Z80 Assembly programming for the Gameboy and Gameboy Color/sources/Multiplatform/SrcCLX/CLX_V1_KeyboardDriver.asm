
; --------------------------------------------------------------------------------------------
;***************************************************************************************************

;			 Keyboard Reader

;***************************************************************************************************
;--------------------------------------------------------------------------------------------
KeyboardScanner_LineCount equ 10
KeyboardScanner_LineWidth equ 8

KeyChar_Backspace equ 10

KeyChar_Enter equ 13

Read_Keyboard:
KeyboardScanner_Read:
	ld hl,KeyboardScanner_KeyPresses    ;Destination Mem for the Keypresses
	ld b,0
	ld c,%10000000 	;Keyboard responds to all ports with mask 10***00*
KeyboardNextLine:
	in a,(c)
	ld (hl),a
	inc hl
	inc b
	ld a,b
	cp %00001010	;Read in from lines ****0000 to ****1001
	jr nz,KeyboardNextLine	
	ret

	ifdef UseHardwareKeyMap
HardwareKeyMap:
		db "1",	" ",	" ",	"l",	"u",	"d",	"x",	"s"
		db "3",	"4",	"E",	"X",	"D",	"C",	" ",	" "
		db "2",	"Q",	"W",	"Z",	"S",	"A",	"t",	" "
		db "5",	"R",	"T",	"V",	"G",	"F",	" ",	" "
		db "6",	"Y",	"H",	" ",	"N",	"B",	" ",	" "
		db "7",	"8",	"U",	"M",	" ",	"J",	" ",	" "
		db "9",	"I",	"O",	",",	" ",	"K",	" ",	" "
		db "0",	"P",	"L",	".",	" ",	";",	" ",	" "
		db "-",	"@",	"I",	"/",	" ",	":",	" ",	" "
		db 10,	"]",	"l",	13,		" ",	"r",	" ",	" "
	endif
KeyboardScanner_AllowJoysticks:
	ret
	
	