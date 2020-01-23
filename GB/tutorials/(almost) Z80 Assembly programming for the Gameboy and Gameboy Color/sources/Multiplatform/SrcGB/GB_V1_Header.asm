BuildGBx equ 1

UserRam equ &D800
ScreenWidth equ 20
ScreenHeight equ 18

ScreenWidth20 equ 1

	org &0000
	
; IRQs


	org &0040						;Vblank Interrupt
	ifdef GBSpriteCache
		Jp VblankInterruptHandler
	else
		reti
	endif
	

sLCDC:
	org &0048
	reti
;sTimer_Overflow:
	org &0050

	reti
;sSerial:
	org &0058
;SECTION	"Serial",HOME($0058)
	reti
;sp1thru4:
;SECTION	"p1thru4",HOME($0060)
	org &0060
	reti

; ****************************************************************************************
; boot loader jumps to here.
; ****************************************************************************************
sstart:
	org &0100
	nop			;0100	0103	Entry point (start of program)
	jp	begin


	;0104	0133	Nintendo logo (must match rom logo)	
	 DB $CE,$ED,$66,$66,$CC,$0D,$00,$0B,$03,$73,$00,$83,$00,$0C,$00,$0D
	 DB $00,$08,$11,$1F,$88,$89,$00,$0E,$DC,$CC,$6E,$E6,$DD,$DD,$D9,$99
	 DB $BB,$BB,$67,$63,$6E,$0E,$EC,$CC,$DD,$DC,$99,$9F,$BB,$B9,$33,$3E

	 DB "EXAMPLE",0,0,0,0,0,0,0,0 ;0134	0142	Game Name (Uppercase)
	 ifdef BuildGMB				  ;0143	0143	Color gameboy flag (&80 = GB+CGB,&C0 = CGB only)
		DB $00
	 endif 
	 ifdef BuildGBC
		DB $80     
	 endif
	 DB 0,0       ;0144	0145	Game Manufacturer code
	 DB 0         ;0146	0146	Super GameBoy flag (&00=normal, &03=SGB)
	 DB 2	  	  ;0147	0147	Cartridge type (special upgrade hardware) (0=normal ROM , 1/2=MBC1(max 2MByte ROM and/or 32KByte RAM)
								;0 - ROM ONLY                12 - ROM+MBC3+RAM
								;1 - ROM+MBC1                13 - ROM+MBC3+RAM+BATT
								;2 - ROM+MBC1+RAM            19 - ROM+MBC5 (max 8MByte ROM and/or 128KByte RAM)
								;3 - ROM+MBC1+RAM+BATT       1A - ROM+MBC5+RAM
								;5 - ROM+MBC2                1B - ROM+MBC5+RAM+BATT
								;6 - ROM+MBC2+BATTERY        1C - ROM+MBC5+RUMBLE
								;8 - ROM+RAM                 1D - ROM+MBC5+RUMBLE+SRAM
								;9 - ROM+RAM+BATTERY         1E - ROM+MBC5+RUMBLE+SRAM+BATT
								;B - ROM+MMM01               1F - Pocket Camera
								;C - ROM+MMM01+SRAM          FD - Bandai TAMA5
								;D - ROM+MMM01+SRAM+BATT     FE - Hudson HuC-3
								;F - ROM+MBC3+TIMER+BATT     FF - Hudson HuC-1
								;10 - ROM+MBC3+TIMER+RAM+BATT
								;11 - ROM+MBC3
			
	 
	 
	 DB 2         ;0148	0148	Rom size (0=32k, 1=64k,2=128k etc)
	 DB 3         ;0149	0149	Cart Ram size (0=none,1=2k 2=8k, 3=32k)
	 DB 1         ;014A	014A	Destination Code (0=JPN 1=EU/US)
	 DB $33       ;014B	014B	Old Licensee code (must be &33 for SGB)
	 DB 0         ;014C	014C	Rom Version Number (usually 0)
	 DB 0         ;014D	014D	Header Checksum - ‘ones complement’ checksum of bytes 0134-014C… not needed for emulators
	 DW 0         ;014E	014F	Global Checksum – 16 bit sum of all rom bytes (except 014E-014F)… unused by gameboy
 
	 
begin:
	nop
	di
	ld	sp, $ffff		; set the stack pointer to highest mem location + 1
	ifdef GBSpriteCache	
		ld bc,DMACopyEnd-DMACopy		;Length of DMA copy code
		ld hl,DMACopy					;Source of DMA copy code
		ld de,VblankInterruptHandler	;Destination (&FF80)
		z_ldir							;Use 'LDIR' Macro (GB doesn't have real LDIR)
	endif

	
	