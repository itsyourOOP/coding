GetHardwareVer:		
	di
	ifdef BuildSMS
		ld de,&0000
	endif
	ifdef BuildSGG
		ld de,&0100
	endif
	
	ret
	

