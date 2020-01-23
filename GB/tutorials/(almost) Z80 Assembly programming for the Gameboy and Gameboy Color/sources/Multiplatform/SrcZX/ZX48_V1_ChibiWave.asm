
ChibiWave:			; We can only support 1 bit wave files on 48k
	ld a,b
	ld (PlayWaveRateSelfMod_Plus1-1),a
	ld ixh,d
	ld ixl,e

Waveagain:
	ld d,(hl)
	ld e,8					;1bit = 8 samples per byte
PlayWaveBitdepthSelfMod_Plus1:
WaveNextBit:
	xor a
	rl d
	rla 
	rlca			;Shift to the right position for the speccy 
	rlca
	rlca
	rlca
	out (&fe),a				;---S-BBB   - Speaker port
	ld b,1					;WaveDelay
PlayWaveRateSelfMod_Plus1:
Wavedelay:					;Wait for next sample
	djnz Wavedelay
	dec e
	jr nz,WaveNextBit
	
	inc hl					;move to next byte
	dec ix
	ld a,ixh		
	or ixl
	jr nz,Waveagain			;Repeat until there are no more bytes
	ret

	
	