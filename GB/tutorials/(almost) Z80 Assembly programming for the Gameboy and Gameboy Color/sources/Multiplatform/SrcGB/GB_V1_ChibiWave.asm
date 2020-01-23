ChibiWave:
	push hl
		ld c,8
		ld hl,Do1BitWav			;1 Bit settings
		or a
		jr z,ChibiWaveBitSet
		ld c,4
		ld hl,Do2BitWav			;2 Bit settings
		dec a
		jr z,ChibiWaveBitSet
		ld c,2
		ld hl,Do4BitWav			;4 Bit settings
ChibiWaveBitSet:
		ld a,l
		ld (r_iyl),a			;Save Call address
		ld a,h
		ld (r_iyh),a
	pop hl
	ld a,c
	z_ld_ixl_c					;Bitdepth
	ld a,b
	z_ld_ixh_b					;Delay
		
Waveagain:
	push de						;Store length for later
		ld d,(hl)
		z_ld_e_ixl				;Get the bits per sample
WaveNextBit:
		xor a
		rl d					;Shift a bit into the sample data
		rla 
		call CallIY				;Call the bitdepth handler
		
		z_ld_b_ixh				;Get the wavedelay
Wavedelay
		z_djnz Wavedelay
		dec e
		jr nz,WaveNextBit
		inc hl
	pop de						;Get Length back
	dec de
	ld a,d						;See if we're done
	or e
	jr nz,Waveagain
	ret
	
CallIY:
	ld (r_r),a					;Back up A
		ld a,(r_iyl)			;Get the fake IY
		ld c,a
		ld a,(r_iyh)
		ld b,a
	push bc						;effectively push 'IY'
	ld a,(r_r)					;Restore A
	ret
	
Do4BitWav:
	rl d
	rla 
	rl d
	rla 
	rl d
	;rla 						;GAMEBOY CAN ONLY DO 3 BIT!
	jr Do1BitWavc
Do2BitWav:
	rl d
	rla 
	jr Do1BitWavb
Do1BitWav:
	rlca
Do1BitWavb:
	rlca
Do1BitWavc
	ld b,a						;Convert to mono
	rlca
	rlca
	rlca
	rlca
	or b
	ld (&FF24),a				;Vol -LLL-RRR
	ret
	
	