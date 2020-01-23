;for tutorial content see : http://www.chibiakumas.com/z80/platform3.php#LessonP27

;DontFreeMemory equ 1	;Define this if you want to KEEP all the extra memory requested

GetHardwareVer:			;returns E=0,1,2 on 64k,128k or 256k enterprise	
	xor a
	ifndef DontFreeMemory	
		ld bc,0				;Put a marker for the last segment
		push bc
	endif
GetMoreMem:
	push af
		rst 6*8		;EXOS call
		db 24		;get a free segment
		;A=nonzero if we're run out of whole free banks
		jp nz,MemFail 
	pop af
	ifndef DontFreeMemory	
		push bc		;Back up C so we can free the segment later
	endif
	inc a		
	jr GetMoreMem
MemFail:
	pop af	;A=4 means 128K A=12 means 256K
	ifndef DontFreeMemory
		ld ixl,a
MemFreeAgain:		
		ld a,c
		or a
		jr z,MemFreeDone
		;call Monitor
		rst 6*8		;EXOS call
		db 25		;Release segment (C)
		pop bc		;Get the next segment to release
		jr MemFreeAgain
MemFreeDone:
		ld a,ixl
	endif
	ld de,0
	cp 4
	ret c
	inc e 
	cp 12
	ret c
	inc e 
	ret


