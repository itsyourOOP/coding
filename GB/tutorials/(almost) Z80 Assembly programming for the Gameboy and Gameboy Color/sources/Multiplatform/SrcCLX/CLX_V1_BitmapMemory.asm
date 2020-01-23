
GetScreenPos:	; BC= X byte - Y line
	push de
		ld hl,&A000
		ld e,0
		ld a,C				;Ypos * 32
		or a
		rr a
		rr e
		rr a
		rr e
		rr a
		rr e
		ld d,a
		ld a,b
		add e				;Add Xpos
		ld e,a
		add hl,de
	pop de
	ex de,hl
	ret
	
	
	