ChibiSound:
	or a
	jr z,silent
	
	xor %00111111	;Frequencies are backwards on the GB!
	ld h,a
	ld a,%01110111 ;-LLL-RRR Channel volume
	ld (&FF24),a
	
	ld a,%10010000	;Low Volume
	bit 6,h
	jr z,LowVol
	ld a,%11110000	;High Volume
LowVol:
	ld (&FF12),a	;Vol
	
	ld a,h
	and %00000111	;Get the low pitch bits
	rrca
	rrca
	rrca
	;ld a,64		;%LLLLLLLL pitch L
	ld (&FF13),a
	
	ld a,h
	and %00111000	;Get the high pitch bits
	rrca
	rrca
	rrca
	or  %10000000	;Turn on the sound
	ld (&FF14),a	;%IC---HHH	C1 Initial / Counter 1=stop / pitch H
	
	bit 7,h
	jr z,NoiseOff
	
	ld a,h
	and %00111000	;Set the noise frequency
	xor %00111000
	rlca
	;rlca
	or %00000111	;'High Quality' Noise
	ld (&FF22),a
	
	
	ld a,(&FF12)	;Copy the volume from the tone chanel to the noise
	ld a,%11111000  ;%VVVVDNNN C1 Volume / Direction 0=down 
	ld (&FF21),a
	
	xor a			;Mute the Tone chanel, enable noise
	ld (&FF12),a	
	ld a,%10001000 ;Mixer LLLLRRRR Channel 1-4 L / Chanel 1-4R
	ld (&FF25),a
						
	ld a,%10000000	;%IC------	C1 Initial / Counter 1=stop
	ld (&FF23),a
	
	
	
	
	ret
	
NoiseOff:
	ld a,%00010001 ;Mixer LLLLRRRR Channel 1-4 L / Chanel 1-4R
	ld (&FF25),a
	xor a			;Mute the noise channel
	ld (&FF21),a
	ret
	
silent:
	ld a,0			;Mute all channels
	ld (&FF25),a
	ret