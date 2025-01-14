			
BROCHE6				EQU 	0x40		; bouton poussoir 1
BROCHE7				EQU 	0x80	; bouton poussoir 2
; The GPIODATA register is the data register
GPIO_PORTD_BASE		EQU		0x40007000		; GPIO Port D (APB) base: 0x4000.7000 (p416 datasheet de lm3s9B92.pdf)
	
; Pul_up
GPIO_I_PUR   		EQU 	0x00000510  ; GPIO Pull-Up (p432 datasheet de lm3s9B92.pdf)
	
; Digital enable register
; To use the pin as a digital input or output, the corresponding GPIODEN bit must be set.
GPIO_O_DEN  		EQU 	0x0000051C  ; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

GPIOIM_OFFSET EQU 0x410

	
		AREA    |.text|, CODE, READONLY
		ENTRY
		
		EXPORT BOUTON_INIT
			
BOUTON_INIT
		; pve switrh up (first)
		ldr r6, = GPIO_PORTD_BASE+GPIO_I_PUR
		ldr r0, = BROCHE6
		str r0, [r6]
		
		ldr r6, = GPIO_PORTD_BASE+GPIO_O_DEN
		ldr	r0, = BROCHE6
		str r0, [r6]
		
		ldr r6, = GPIO_PORTD_BASE+(BROCHE6<<2)
		
		; pve swiwth bottom (second)
		ldr r7, = GPIO_PORTD_BASE+GPIO_I_PUR
		ldr r0, [r7]
		orr r0, r0, #BROCHE7
		str r0, [r7]
		
		ldr r7, = GPIO_PORTD_BASE+GPIO_O_DEN
		ldr r0, [r7]
		orr	r0, r0, #BROCHE7
		str r0, [r7]
		
		ldr r7, = GPIO_PORTD_BASE+(BROCHE7<<2)
		
		
		ldr r5, = GPIO_PORTD_BASE+GPIOIM_OFFSET
		ldr r0, [r5]
		orr	r0, r0, #0xC0
		str r0, [r5]
		
		
		
		BX	LR	; FIN du sous programme d'init.
		END
loop 
		ldr r10,[r6]
		CMP r10,#0x00
		BEQ top_button
		
		ldr r11,[r7]
		CMP r11,#0x00
		
		BEQ bottom_button
		BNE loop

bottom_button
	ldr r6, = 0x10 ; on fait ce qu'on veut
	b BOUTON_INIT
	
top_button
	ldr r7, = 0x10 ; on fait ce qu'on veut 
	b BOUTON_INIT
	
		BX	LR	; FIN du sous programme d'init.
		END