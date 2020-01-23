ChibiSound:			;NVTTTTTT	Noise Volume Tone 
	or a
	jr z,silent		;Zero turns off sound
	
	ld h,a			;Back up A
	and %00000111	;Rotate lowest 3 bits from -----XXX
	rrca
	rrca
	rrca
	or %00011111	;convert 11100000 to 11111111
	ld c,a
	ld a,0			;TTTTTTTT Tone Lower 8 bits	A
	call AYRegWrite

	ld a,h
	and %00111000	;Get upper bits of tone
	rrca
	rrca
	rrca
	ld c,a
	ld a,1			;----TTTT Tone Upper 4 bits
	call AYRegWrite
	
	bit 7,h			;Noise bit N-------
	jr z,AYNoNoise

	ld a,7			;Mixer  --NNNTTT (1=off) --CBACBA
	ld c,%00110110
	call AYRegWrite

	ld a,6			;Noise ---NNNNN
	ld c,%00011111
	call AYRegWrite

	jr AYMakeTone
AYNoNoise:
	ld a,7			;Mixer  --NNNTTT (1=off) --CBACBA
	ld c,%00111110
	call AYRegWrite
	jr AYMakeTone
AYMakeTone:
;*** these are incorrectly marked as Amplitude Control (Reg R10,R11,R12) in some documentation! ***
	ld a,h
	and %01000000	;-V------ = Volume bit
	rrca
	rrca
	rrca
	rrca
	or  %00001011	;Shift the high volume bit into position
	ld c,a
	ld a,8			;4-bit Volume / 2-bit Envelope Select for channel A ---EVVVV
	call AYRegWrite
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
silent:
	ld a,7		;Mixer  --NNNTTT (1=off) --CBACBA
	ld c,%00111111
	call AYRegWrite

	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
AYRegWrite:
	ifdef BuildCPC
		push bc
			ld b,&f4
			ld c,a
			out (c),c	;#f4 Regnum

			ld bc,&F6C0	;Select REG
			out (c),c	

			ld bc,&f600	;Inactive
			out (c),c

			ld bc,&F680	;Write VALUE
			out (c),c	
		pop bc

		ld b,&F4		;#f4 value
		out (c),c

		ld bc,&f600		;inactive
		out (c),c
		ret
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	ifdef BuildZXS
		push bc
			ld bc,&FFFD
			out (c),a	;Regnum
		pop bc
AYRegWriteQuick:
		ld a,c
		ld bc,&BFFD
		out (c),a	;Value
		ret
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef BuildMSX
		push bc
			out (#a0),a	;regnum
		pop bc
AYRegWriteQuick:
		ld a,c
		out (#a1),a	;value
		ret
	endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;