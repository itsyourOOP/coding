EnableFastCPU:
	ld a,0
	ld (&FFFF),a	;Disable Interrupts
	
	ld a,%00110000
	ld (&FF00),a	;Set Joypad bits 4,5
	
	ld a,1
	ld (&FF4D),a	;Pepare for speed change
	stop			;Speed change actually occurs
	ret
	
	