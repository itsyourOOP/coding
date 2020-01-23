ConfigureControls:
	ret



Player_ReadControlsDual:
	in a,(%11111010)
	ld h,a
	in a,(%11111011)
	ld l,a
	ret