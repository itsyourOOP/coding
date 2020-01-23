gbz80 equ 1

;Fake registers in GB Ram
r_ixl equ &DFF0	
r_ixh equ &DFF1
r_ix  equ &DFF0
	
r_iyl equ &DFF2
r_iyh equ &DFF3
r_iy  equ &DFF2

r_r   equ &DFF4

;Shadow Regs
rs_a  equ &DFF5
rs_f  equ &DFF6

rs_b  equ &DFF7
rs_c  equ &DFF8

rs_d  equ &DFF9
rs_e  equ &DFFA

rs_h  equ &DFFB
rs_l  equ &DFFC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_neg
		cpl
		inc a
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	macro z_ex_sphl		;ex (SP),HL
		push de			;Backup DE
			ld d,h
			ld e,l
			
			inc sp		;Move back to SP position before pushing
			inc sp
			
			pop hl		;Grab the value that was on the top of the stack
			push de		;Put what was HL onto the stack
			
			dec sp		;Return to the last position
			dec sp
		pop de			;Restore DE
	endm
	
	macro z_ex_dehl
		push hl			;Push HL and DE on the stack, then pop them
		push de			;	in the opposite order
		pop hl
		pop de
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	macro z_ldi
	push af
		ld a,(hl)		;Copy a byte from (HL) to (DE) and inc the counter
		ld (de),a
		inc hl
		inc de
		dec bc
	pop af
	endm
	
	macro z_ldir
	push af
 \@Ldirb:			;Fake LDIR, copy BC bytes from HL to DE
		ld a,(hl)
		ld (de),a
		inc hl
		inc de
		dec bc
		ld a,b
		or c
		jr nz, \@Ldirb
	pop af
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;BUG:When interrupts are disabled with DI, HALT will not lock the cpu... GBZ80 skips it, but The instruction immediately following the  HALT instruction is "skipped" on all except the GBC. As a result, always put a NOP after the HALT instruction.
	macro z_halt
		halt
		nop
	endm	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_or_ixl
		push hl
			ld hl,r_ixl		;Use fake register in memory via HL
			or (hl)
		pop hl
	endm
	macro z_or_ixh
		push hl
			ld hl,r_ixh		;Use fake register in memory via HL
			or (hl)
		pop hl
	endm
	macro z_or_iyl
		push hl
			ld hl,r_iyl		;Use fake register in memory via HL
			or (hl)
		pop hl
	endm
	macro z_or_iyh
		push hl
			ld hl,r_iyh		;Use fake register in memory via HL
			or (hl)
		pop hl
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		macro z_ld_iy_plusn_a,aoffset	; Fake LD (Iy+n),a
			push hl
			push de
				push af
					ld a,(r_iyl)		;Get address into HL
					ld l,a
					ld a,(r_iyh)
					ld h,a
					ld de,\aoffset		;Add the offset
					add hl,de
				pop af
				ld (hl),a 				;ld (iy + \aoffset),a
			pop de
			pop hl
		endm
		
		macro z_ld_iy_plusn_n,aoffset,aval	;Store an immidiate value into an (IY+n)
			push hl							; this mimmics LD (IY+2),&FF  - or similar
			push de
				push af
					ld a,(r_iyl)
					ld l,a
					ld a,(r_iyh)
					ld h,a
					ld de,\aoffset
					add hl,de
				pop af
				ld (hl),\aval 			;ld (iy + \aoffset),\aval
			pop de
			pop hl

		endm
		
		macro z_ld_iy_plusn_h,aoffset
			push af
			push de
				push hl
					ld a,h
					push af
						ld a,(r_iyl)
						ld l,a
						ld a,(r_iyh)
						ld h,a
						ld de,\aoffset
						add hl,de
					pop af
					ld (hl),a	;ld (iy + \aoffset),h
				pop hl
			pop de
			pop af
			
		endm
		macro z_ld_iy_plusn_l,aoffset
			push af
			push de
				push hl
					ld a,l
					push af
						ld a,(r_iyl)
						ld l,a
						ld a,(r_iyh)
						ld h,a
						ld de,\aoffset
						add hl,de
					pop af
					ld (hl),a	;ld (iy + \aoffset),l
				pop hl
			pop de
			pop af
		endm		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_djnz,addr
		dec b					;Decrease B
		jp nz,\addr				;Jump if not zero
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_ld_a_r				;I use R as a random source 
		LD a,(r_r)				;this will do some kind of random generaton
		inc a
		xor h
		xor l
		rlca
		xor b
		xor c
		rlca
		xor d
		xor e
		ld (r_r),a
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_ld_a_iyl			;Load A from one of the fake memory based registers
		LD a,(r_iyl)
	endm
	macro z_ld_a_iyh
		LD a,(r_iyh)
	endm
	
	macro z_ld_a_ixl
		LD a,(r_ixl)
	endm
	macro z_ld_a_ixh
		LD a,(r_ixh)
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_ld_iyl_a
		LD (r_iyl),a			;Store A from one of the fake memory based registers
	endm
	macro z_ld_iyh_a
		LD (r_iyh),a
	endm
	
	macro z_ld_ixl_a
		LD (r_ixl),a
	endm
	macro z_ld_ixh_a
		LD (r_ixh),a
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_cp_iyl
		push hl
			ld hl,r_iyl		;Compare IYL via HL
			cp (hl)			;this means the flags are affected correctly
		pop hl
	endm
	macro z_cp_iyh
		push hl
			ld hl,r_iyh
			cp (hl)
		pop hl
	endm
	
	macro z_cp_ixl
		push hl
			ld hl,r_ixl
			cp (hl)
		pop hl
	endm
	macro z_cp_ixh
		push hl
			ld hl,r_ixh
			cp (hl)
		pop hl
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_inc_ixl
		push hl
			ld hl,r_ixl		;Increase IXL, by loading it into HL
			inc (hl)		;Then decreasing it, this means the flags 
		pop hl				;should be affected correctly
	endm
	macro z_inc_ixh
		push hl
			ld hl,r_ixh
			inc (hl)
		pop hl
	endm
	macro z_inc_iyl
		push hl
			ld hl,r_iyl
			inc (hl)
		pop hl
	endm
	macro z_inc_iyh
		push hl
			ld hl,r_iyh
			inc (hl)
		pop hl
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_dec_ixl
		push hl
			ld hl,r_ixl		;Decrease IXL, by loading it into HL
			dec (hl)		;Then decreasing it, this means the flags 
		pop hl				;should be affected correctly
	endm
	macro z_dec_ixh
		push hl
			ld hl,r_ixh
			dec (hl)
		pop hl
	endm
	macro z_dec_iyl
		push hl
			ld hl,r_iyl
			dec (hl)
		pop hl
	endm
	macro z_dec_iyh
		push hl
			ld hl,r_iyh
			dec (hl)
		pop hl
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	macro z_inc_iy
		push de
		push hl
			ld hl,r_iy
			ld e,(hl)		;Load in the fake IY to DE
			inc hl
			ld d,(hl)
			
			inc de			;Increase the fake IY
			
			ld (hl),d		;Save it back
			dec hl			
			ld (hl),e
		pop hl
		pop de
	endm	
	macro z_dec_iy
		push de
		push hl
			ld hl,r_iy
			ld e,(hl)
			inc hl
			ld d,(hl)
			dec de
			ld (hl),d
			dec hl
			ld (hl),e
		pop hl
		pop de
	endm	
		macro z_inc_ix
		push de
		push hl
			ld hl,r_ix
			ld e,(hl)
			inc hl
			ld d,(hl)
			inc de
			ld (hl),d
			dec hl
			ld (hl),e
		pop hl
		pop de
	endm	
	macro z_dec_ix
		push de
		push hl
			ld hl,r_ix
			ld e,(hl)
			inc hl
			ld d,(hl)
			dec de
			ld (hl),d
			dec hl
			ld (hl),e
		pop hl
		pop de
	endm	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_sbc_hl_de	;Subtract DE from HL
	
	push de
		push af
			ld a,d		;Negate DE
			cpl
			ld d,a
			ld a,e
			cpl
			ld e,a
		pop af
		push af
			jr c, \@z_sbc_hl_de	
			inc de
 \@z_sbc_hl_de:
			add hl,de	;Note - this isn't using the carry, 
		pop af			;but honestly it's not something I've ever used
	pop de 
	
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_sbc_hl_bc		;Subtract BC from HL
	push bc
		push af
			ld a,b			;Negate bc
			cpl
			ld b,a
			ld a,c
			cpl
			ld c,a
		pop af
		jr c,.z_sbc_hl_de	
		inc bc
.z_sbc_hl_de
		add hl,bc		;Note - this isn't using the carry, 
	pop bc				;but honestly it's not something I've ever used
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_ld_bc_from,addr	;GBZ80 can't load a register pair from an address in one go 
	push hl					;like... LD BC,(addr)
		ld hl,\addr			;We can fake it using HL to write from the address
		ld c,(hl)
		inc hl
		ld b,(hl)
	pop hl
	endm
	macro z_ld_de_from,addr
	push hl
		ld hl,\addr
		ld e,(hl)
		inc hl
		ld d,(hl)
	pop hl
	endm
	macro z_ld_hl_from,addr
	push af
		ld hl,\addr
		ld a,(hl)
		inc hl
		ld h,(hl)
		ld l,a
	pop af
	endm
	
		macro z_ld_ix_from,addr
			push af
				ld a,(\addr)			;Load in A from the address
				ld (r_ixl),a			;save into the low part
				ld a,(\addr+1)			;Load in A from addr+1
				ld (r_ixh),a			;Save into the high part
				
			pop af
		endm
		macro z_ld_iy_from,addr
			push af
				ld a,(\addr)			;Load in A from the address
				ld (r_iyl),a			;save into the low part
				ld a,(\addr+1)			;Load in A from addr+1
				ld (r_iyh),a			;Save into the high part
			pop af
		endm
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
	macro z_ld_bc_to,addr	;GBZ80 can't load a register pair to an address in one go 
		push hl				;like... LD (addr),BC
			ld hl,\addr		;We can fake it using HL to write to the address
			ld (hl),c
			inc hl
			ld (hl),b
		pop hl
	endm
	macro z_ld_de_to,addr
		push hl
			ld hl,\addr
			ld (hl),e
			inc hl
			ld (hl),d
		pop hl
	endm
	macro z_ld_hl_to,addr
		push af
		push de
			ld de,\addr
			ld a,l
			ld (de),a
			inc de
			ld a,h
			ld (de),a
		pop de
		pop af
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
		macro z_ld_ix_to,addr
			push af
				ld a,(r_ixl)	;Save fake IX to an address 
				ld (\addr),a
				ld a,(r_ixh)
				ld (\addr+1),a
			pop af
		endm
		macro z_ld_iy_to,addr
			push af
				ld a,(r_iyl)
				ld (\addr),a
				ld a,(r_iyh)
				ld (\addr+1),a
			pop af
		endm
		
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
		macro z_ld_ix,valu
			push af
			push hl
				ld hl,\valu		;Load a 16 bit value into fake IX via HL
				ld a,l
				ld (r_ixl),a
				ld a,h
				ld (r_ixh),a
			pop hl
			pop af
		endm
		macro z_ld_iy,valu
			push af
			push hl
				ld hl,\valu
				ld a,l
				ld (r_iyl),a
				ld a,h
				ld (r_iyh),a
			pop hl
			pop af
		endm
		
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
		macro z_ld_ixl,valu
			push af
				ld a,\valu		;Transfer Immediate value into fake IXL
				ld (r_ixl),a
			pop af
		endm
		macro z_ld_ixh,valu
			push af
				ld a,\valu
				ld (r_ixh),a
			pop af
		endm
		macro z_ld_iyl,valu
			push af
				ld a,\valu
				ld (r_iyl),a
			pop af
		endm
		macro z_ld_iyh,valu
			push af
				ld a,\valu
				ld (r_iyh),a
			pop af
		endm
		
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	macro z_ld_b_ixl
		push af
			ld a,(r_ixl)	;transfer the shadow IXL reg into B
			ld b,a
		pop af
	endm
	macro z_ld_c_ixl
		push af
			ld a,(r_ixl)
			ld c,a
		pop af
	endm
	macro z_ld_d_ixl
		push af
			ld a,(r_ixl)
			ld d,a
		pop af
	endm
	macro z_ld_e_ixl
		push af
			ld a,(r_ixl)
			ld e,a
		pop af
	endm
	macro z_ld_h_ixl
		push af
			ld a,(r_ixl)
			ld h,a
		pop af
	endm
	macro z_ld_l_ixl
		push af
			ld a,(r_ixl)
			ld l,a
		pop af
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	macro z_ld_b_ixh
		push af
			ld a,(r_ixh)	;transfer the shadow IXH reg into B
			ld b,a
		pop af
	endm
	macro z_ld_c_ixh
		push af
			ld a,(r_ixh)
			ld c,a
		pop af
	endm
	macro z_ld_d_ixh
		push af
			ld a,(r_ixh)
			ld d,a
		pop af
	endm
	macro z_ld_e_ixh
		push af
			ld a,(r_ixh)
			ld e,a
		pop af
	endm
	macro z_ld_h_ixh
		push af
			ld a,(r_ixh)
			ld h,a
		pop af
	endm
	macro z_ld_l_ixh
		push af
			ld a,(r_ixh)
			ld l,a
		pop af
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	macro z_ld_ixl_b
		push af
			ld a,b			;transfer B into the shadow IXL reg
			ld (r_ixl),a
		pop af
	endm
	macro z_ld_ixl_c
		push af
			ld a,c
			ld (r_ixl),a
		pop af
	endm
	macro z_ld_ixl_d
		push af
			ld a,d
			ld (r_ixl),a
		pop af
	endm
	macro z_ld_ixl_e
		push af
			ld a,e
			ld (r_ixl),a
		pop af
	endm
	macro z_ld_ixl_h
		push af
			ld a,h
			ld (r_ixl),a
		pop af
	endm
	macro z_ld_ixl_l
		push af
			ld a,l
			ld (r_ixl),a
		pop af
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	macro z_ld_ixh_b
		push af
			ld a,b			;transfer B into the shadow IXH reg
			ld (r_ixh),a
		pop af
	endm
	macro z_ld_ixh_c
		push af
			ld a,c
			ld (r_ixh),a
		pop af
	endm
	macro z_ld_ixh_d
		push af
			ld a,d
			ld (r_ixh),a
		pop af
	endm
	macro z_ld_ixh_e
		push af
			ld a,e
			ld (r_ixh),a
		pop af
	endm	
	macro z_ld_ixh_h
		push af
			ld a,h
			ld (r_ixh),a
		pop af
	endm
	macro z_ld_ixh_l
		push af
			ld a,l
			ld (r_ixh),a
		pop af
	endm
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro gb_swap_a				;These are special GB commands
		swap a					;We can emulate them on the Z80
	endm						;with 4x RLCA
	macro gb_swap_b
		swap b
	endm
	macro gb_swap_c
		swap c
	endm
	macro gb_swap_d
		swap d
	endm
	macro gb_swap_e
		swap e
	endm
	macro gb_swap_f
		swap f
	endm
	macro gb_swap_h
		swap h
	endm
	macro gb_swap_l
		swap l
	endm
	macro gb_swap_hl
		swap (hl)
	endm
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	macro z_ex_af_afs
		push bc
		push de
			push af				;Transfer AF to DE
			pop de
			
			ld a,(rs_a)			;Get the shadow AF into BC
			ld b,a
			ld a,(rs_f)
			ld c,a
			
			ld a,d
			ld (rs_a),a			;Save the prevous AF
			ld a,e
			ld (rs_f),a
			
			push bc				;Transfer the ShadowAF from BC to AF
			pop af
			
		pop de
		pop bc
	endm
	
	macro z_exx
		push af
		push bc
			ld b,h				;Backup HL into BC
			ld c,l
			
			ld a,(rs_h)			;Pull HL out of the fake shadow regs
			ld h,a
			ld a,(rs_l)
			ld l,a
			
			ld a,b				;Store the backed up HL in the shadow regs
			ld (rs_h),a
			ld a,c
			ld (rs_l),a
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			ld b,d
			ld c,e
			
			ld a,(rs_d)			;Do the same with DE
			ld d,a
			ld a,(rs_e)
			ld e,a
			
			ld a,b
			ld (rs_d),a
			ld a,c
			ld (rs_e),a
		pop bc
		push hl
			ld h,b
			ld l,c
			
			ld a,(rs_b)			;Do the same with BC
			ld b,a
			ld a,(rs_c)
			ld c,a
			
			ld a,h
			ld (rs_b),a
			ld a,l
			ld (rs_c),a
		pop hl
		pop af
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; there seems to be a bug in VASM - it thinks the GBZ80 doesn't support SRL, but it does! --- FIXED IN LATEST VERSION
;	macro z_srl_a
		;db &CB,&3F
	;endm
;	macro z_srl_h
		;db &CB,&3C
	;endm