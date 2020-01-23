ChibiWave:
	push hl
		ld c,8					;1 Bit settings
		ld hl,Do1BitWav
		or a
		jr z,ChibiWaveBitSet		
		ld c,4					;2 Bit settings
		ld hl,Do2BitWav
		dec a
		jr z,ChibiWaveBitSet
		ld c,2					;4 Bit settings
		ld hl,Do4BitWav
ChibiWaveBitSet:
		push hl
		pop iy					;Store command in IY
	pop hl
	ld ixl,c					;Bit Depth
	ld ixh,b					;Delay
	
	; Sending a value
Waveagain:
	push de						;Back up length
	
		ld d,(hl)				;Load in a Sample
		ld e,ixl				;Samples per byte
WaveNextBit:
		xor a
		rl d					;Shift first bit into D
		rla 
		call CallIY				;'Call' IY (the correct sample command)
		
		ld b,ixh				;Wave Delay
Wavedelay:
		djnz Wavedelay
		dec e
		jr nz,WaveNextBit		;Process andy remaning bits
		inc hl
	pop de
	dec de						;Decrease vyte counter
	ld a,d
	or e
	jr nz,Waveagain				;Repeat until there's no more bytes
	ret
CallIY
	jp (iy)						;Jump to IY
	
Do4BitWav:
	rl d						;Shift 4 bits in
	rla 
	rl d
	rla 
	rl d
	rla 
	jr Do1BitWavc
Do2BitWav:
	rl d						;Shift 2 bits in
	rla 
	jr Do1BitWavb
Do1BitWav:
	rlca						;Move bits into correct pos
Do1BitWavb:
	rlca
	rlca
Do1BitWavc:
	or %11010000			;Set Volume %1101VVVV
	out (&7F),a
	ret
	
	