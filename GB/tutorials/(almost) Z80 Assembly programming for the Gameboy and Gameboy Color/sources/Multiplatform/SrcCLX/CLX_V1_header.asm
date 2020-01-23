	
	
ScreenWidth32 equ 1
ScreenHeight24 equ 1
ScreenWidth equ 32
ScreenHeight equ 24
	
	org &6500	
	di
	xor a
	out (%10000100),a	;Mute noise!