ShowDecimal:
DrawText_Decimal:	;Draw a 3 digit decimal number (non-BCD)
	ld hl,&640A
	ld b,a		
	
	cp h
	jr nc,DecThreeDigit
	
	call PrintSpace
	cp l 
	jr nc,SkipDigit100
	call PrintSpace
	jr SkipDigit10
	
	
	;ld a,&C4	;CallNZ selfmod	
	;ld (DrawTextForceZeroCall_Plus3-3),a
	;ld a,b
	;cp h		;We need to draw 0 of second digit if value is >100
	;jr c,SkipDigit100
	;ld a,&CD	;Call selfmod
;	ld (DrawTextForceZeroCall_Plus3-3),a
DecThreeDigit

	call DrawTextDecimalSub
	;call DrawText_CharSprite48
SkipDigit100:
	ld h,l
	call DrawTextDecimalSub
	;call DrawText_CharSprite48	
DrawTextForceZeroCall_Plus3:
SkipDigit10:
	ld a,b
DrawText_CharSprite48:
	add 48
DrawText_CharSpriteProtectBC:
	;push bc
	jp PrintChar; draw char
	;pop bc
	;ret
	

DrawTextDecimalSub:
	ld a,b
	ld c,0
DrawText_DecimalSubagain:
	cp h
	jr c,DrawText_DecimalLessThan	;Devide by 100
	inc c
	sub h
	jr DrawText_DecimalSubagain
DrawText_DecimalLessThan:
	ld b,a
	ld a,c
	or a		;We're going to do a compare as soon as we return
	jr DrawText_CharSprite48
	