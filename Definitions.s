
		AREA     |.rodata|, DATA, READONLY
		
		EXPORT steps
		EXPORT length_steps
		EXPORT flag_main_loop
			
length_steps
		DCD 0x4 ; length 
steps		
		DCD 0x80 ; position_right
		DCD 0x40 ; position left, we can put negative value
		DCD 200 ; speed right
		DCD 100 ; speed left
		
		DCD 0x40
		DCD 0x80
		DCD 100
		DCD 200
			
		DCD 0x80 ; position_right
		DCD 0x40 ; position left, we can put negative value
		DCD 200 ; speed right
		DCD 100 ; speed left
		
		DCD 0x40
		DCD 0x80
		DCD 100
		DCD 200
flag_main_loop
    DCD 0    