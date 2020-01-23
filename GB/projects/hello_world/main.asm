;; Hello World Program (heavily commented) ;;

INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]
    ; Our code here

EntryPoint: ; program actually *starts* here
	di ; Disables interrupts, we don't need them for this
	jp Start ; presumably jumps to a label called Start, where we'll *actually* start the program

REPT $150 - $104 ; seems to be "repeat from memory location $104 to $150, reset a byte"
	db 0 ; which is more or less filling that range of memory with zeros. 
ENDR

SECTION "Game Code", ROM0

; First step is to copy the font data to the VRAM

; we need to *access* VRAM, and to do that the LCD needs to be off. 
; to do that, we reset bit 7 of LCDC
; but we also gotta do it during VBlank

Start: ; see, this is where that jp instruction jumps to
	; okay now we need to turn off the LCD, but we gotta first check if it's VBlank

; checks if VBlank is done, and when it is sets the entire rLCDC register to 0 to turn off the LCD.
.waitVBlank
	ld a, [rLY]
	cp 144 ; Check if the LCD is past VBlank
	jr c, .waitVBlank ; "c" here is for carry. This checks if the carry bit has been set, and if it has we just start over again. 

	; remember that the carry bit is only set during cmp when a is less than the given immediate.

	xor a ; this is equivalent to ld a, 0. XORing a with itself will always be zero.  
	ld [rLCDC], a ; We only need to reset the 7th bit of rLCDC, but 0's fine. We're gonna write to the "register" again anyway.


; alrighty, the LCD is now off. Now we can copy the font data to VRAM.

	ld hl, $9000 ; this is a location in VRAM
	ld de, FontTiles ; loads the address of the font tiles into de
	ld bc, FontTilesEnd - FontTiles ; loads the length of that memory space into bc
.copyFont
	ld a, [de] ; grab 1 byte from the source
	ld [hli], a ; place it at the destination (which is memory location $9000 during the first run-through), and increments hl
	inc de ; move to next byte
	dec bc ; decrement counter
	ld a, b ; check if count is 0, since 'dec bc' doesn't increment flags
	or c ; b or c, for this to equal zero, both have to be 0, all bits for both need to be 0. 
	jr nz, .copyFont ; if count is not zero, loop again. 

	ld hl, $9800 ; this prints the string at the top-left corner of the screen, by copying the string "somewhere" into VRAM
	ld de, HelloWorldStr ; loads the address of the "hello world" string

.copyString
	ld a, [de] ; grab 1 byte from the string
	ld [hli], a ; place that byte at the memory location (which is $9800 during the first run-through), also increments hl
	inc de ; move to next byte in the string
	and a ; and a, a ; checks if the byte we copied was zero
	jr nz, .copyString ; if a != 0, the zero flag won't be set, else if a == 0, the z flag will be set and the loop will be exited

; the reason we're checking if the current byte is 0 is because that's this: \0
; the null terminator is at the end of the string, and is what *determines* where a string ends. If we hit it, we got the whole string. 

; Initialize display registers
ld a, %11100100 ; initializing the palette. %11100100 is %11, %10, %01, %00. These represent 4 types of colors. 
ld [rBGP], a

xor a ; ld a, 0
ld [rSCY], a ; setting the upper-left corner of the screen to (0, 0)
ld [rSCX], a 

; Shut sound down
ld [rNR52], a

; Turn screen on, display background
ld a, %10000001 
ld [rLCDC], a

; time to trap the CPU into an infinite loop, this will keep it from causing issues

; Lock up
.lockup
	jr .lockup

; Okayyyy, now time to actually *give* the program the font and string. Let's make another section for the font. 

SECTION "Font", ROM0

FontTiles:
INCBIN "font.chr" ; makes RGBDS copy the contents of the file (here, font.chr) directly into the rom
FontTilesEnd:

; now lets give it the string. Another section!

SECTION "Hello World String", ROM0

HelloWorldStr: ; really, you can see how things work by changing this
	db "Hallo Spaceboy!", 0 ; db tells the assember to place some bytes of data (dw is for 16-bit words, and dl is for 32-bit longs)
	; you can use db for strings, which are automatically encoded in ASCII. 
	; the 0 tells the copy function to stop. I'm assuming that's meant to be the null terminator. 

; okay! We're done! Now assemble this bad boy!
; from the future, and it works with whatever string you give it!

; it's not *too* different from MIPS, just has these weird SECTION things. Otherwise, they're pretty similar. 