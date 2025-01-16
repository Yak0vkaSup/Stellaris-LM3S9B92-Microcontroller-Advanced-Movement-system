
		AREA     |.rodata|, DATA, READONLY
		
		EXPORT list_A
		EXPORT list_B
		
list_A
		DCD 0x2 ; length 
		DCD steps_A
steps_A	
		DCD 0x80 ; position_right
		DCD 0x40 ; position left, we can put negative value
		DCD 100 ; speed right
		DCD 50 ; speed left
			
		DCD 0x80 ; position_right
		DCD 0x40 ; position left, we can put negative value
		DCD 100 ; speed right
		DCD 50 ; speed left
		
list_B
		DCD 0x2
		DCD steps_B
steps_B
		DCD 0x80 ; position_right
		DCD 0x80 ; position left, we can put negative value
		DCD 100 ; speed right
		DCD 100 ; speed left
			
		DCD 0x80 ; position_right
		DCD 0x80 ; position left, we can put negative value
		DCD 100 ; speed right
		DCD 100 ; speed left