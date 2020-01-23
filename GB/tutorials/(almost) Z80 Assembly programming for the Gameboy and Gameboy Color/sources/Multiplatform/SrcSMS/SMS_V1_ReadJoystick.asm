Player_ReadControlsDual:	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;			Get Player 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

	ifdef BuildSGG	
		ld a,255		;Blank player 2 on the SGG
	endif
	ifdef BuildSMS
		push bc
			in a,(&DC)	;UD are in Player1's port
			ld b,a
			in a,(&DD)	;Most of player 2's keys
			rl b		;Shift 2 of the bits into A
			rla
			rl b
			rla
			or %11000000	;Fill the 2 bits (6,7 of port A)
		pop bc
	endif
	ld l,a ;= Keypress bitmap Player 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;			Get Player 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	ifdef BuildSGG
		push bc
		in a,(&0)
		or %01111111	;bit 7 is the start button
		ld b,a
	endif
	in a,(&DC)
	or %11000000		;Fill bits 6,7 of port A - these were player 2
	ifdef BuildSGG
		and b
		pop bc
	endif
	ld h,a ;= Keypress bitmap Player 1
	
BootsStrap_ConfigureControls:
	ret
	
	
	
;Port $DC: I/O port A and B
;Bit 	Function 
;7 	Port B Down pin input 
;6 	Port B Up pin input 
;5 	Port A TR pin input 
;4 	Port A TL pin input 
;3 	Port A Right pin input 
;2 	Port A Left pin input 
;1 	Port A Down pin input 
;0 	Port A Up pin input 


;Port $DD: I/O port B and miscellaneous
;Bit	Function 
;7 	Port B TH pin input (Unused)
;6 	Port A TH pin input (Unused)
;5 	Cartridge slot CONT pin * 
;4 	Reset button (1= not pressed, 0= pressed) * 
;3 	Port B TR pin input 
;2 	Port B TL pin input 
;1 	Port B Right pin input 
;0	Port B Left pin input

;The Game Gear has three face buttons: buttons 1 and 2 as in the Master System, and additionally a Start button.

;When running in Game Gear mode, the Start button state may be read by inputting from port $00; bit 7 reflects its state, with active-low logic (1 = not pressed, 0 = pressed). 