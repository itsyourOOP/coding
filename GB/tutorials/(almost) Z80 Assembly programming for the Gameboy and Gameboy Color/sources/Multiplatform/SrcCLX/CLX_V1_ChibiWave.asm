
ChibiWave:
	push hl
		ld c,8						;1 Bit settings
		ld hl,Do1BitWav
		or a
		jr z,ChibiWaveBitSet		
		ld c,4						;2 Bit settings
		ld hl,Do2BitWav
		dec a
		jr z,ChibiWaveBitSet
		ld c,2						;4 Bit settings
		ld hl,Do4BitWav
ChibiWaveBitSet:
		;Selfmod the settings in for the settings
		ld (PlayWaveCallSelfMod_Plus2-2),hl
	pop hl
	ld a,c
	ld (PlayWaveBitdepthSelfMod_Plus1-1),a
	ld a,b
	ld (PlayWaveRateSelfMod_Plus1-1),a

	ld ixh,d						;Move Length into IX
	ld ixl,e

Waveagain:
	ld d,(hl)						;Load in sample
	ld e,2							;Samples per byte
PlayWaveBitdepthSelfMod_Plus1:
WaveNextBit:
	xor a							;Shift first bit into D
	rl d
	rla 

	call Do4BitWav					;Call correct wave function 
PlayWaveCallSelfMod_Plus2:			;This is Self-Modified depending
									;on bit depth
									
	ld b,1							;WaveDelay
PlayWaveRateSelfMod_Plus1:
Wavedelay:							;Wait for next sample
	djnz Wavedelay
	
	dec e
	jr nz,WaveNextBit				;Process any remaining bits
	inc hl

	dec ix
	ld a,ixh		
	or ixl
	jr nz,Waveagain					;Repeat until there are no more bytes
	
	xor a
	out (%10000100),a				;Turn off sound 
	ret
Do4BitWav:
	rl d							;Shift 4 bits in
	rla 
	rl d
	rla 
	rl d
	rla 
	jr Do1BitWavc
Do2BitWav:
	rl d							;Shift 2 bits in
	rla 
	jr Do1BitWavb
Do1BitWav:
	rlca							;Move bits into correct pos
Do1BitWavb:
	rlca
	rlca
Do1BitWavc
	rlca							;Lynx takes a 6 bit volume
	rlca
	out (%10000100),a				; 0-VVVVVV	
	
	ret
	
	