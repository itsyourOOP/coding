ChibiSound:
	or a
	jr z,silent
	ld h,a
         ;1CCTLLLL	(Latch - Channel Type DataL
	ld a,%11001111	; Low Tone
	out (&7F),a
	ld a,h
		;0-HHHHHH
	and %00111111	;High Tone
	out (&7F),a

	ld a,h
	and %01000000
	rrca
	rrca
	rrca
	rrca
	ld l,a
	xor %11010100	;Set Volume
	out (&7F),a
	ld a,%11111111	;Mute noise
	out (&7F),a

	bit 7,h		;We're done if there is no noise
	ret z

	ld a,%11011111	;1CCTVVVV	(Latch - Channel Type Volume)	
	out (&7F),a

	ld a,%11100111	;1CCT-MRRr	(Latch - Channel Type... noise Mode (1=white) Rate (Rate 11= use Tone Channel 2)
	out (&7F),a

	ld a,l
	xor %11110100	;Set Volume
	out (&7F),a

	ret

silent:	;Mute both channels
		
		 ;1CCTVVVV
	ld a,%11111111	;Vol=15 means mute
	out (&7F),a
	ld a,%11011111	
	out (&7F),a
	ret
