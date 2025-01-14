
; Broches select
BROCHE4_5			EQU		0x30		; led1 & led2 sur broche 4 et 5
	
; blinking frequency
DUREE   			EQU     0x002FFFFF
; The GPIODATA register is the data register
GPIO_PORTF_BASE		EQU		0x40025000	; GPIO Port F (APB) base: 0x4002.5000 (p416 datasheet de lm3s9B92.pdf)

; configure the corresponding pin to be an output
; all GPIO pins are inputs by default
GPIO_O_DIR   		EQU 	0x00000400  ; GPIO Direction (p417 datasheet de lm3s9B92.pdf)

; The GPIODR2R register is the 2-mA drive control register
; By default, all GPIO pins have 2-mA drive.
GPIO_O_DR2R   		EQU 	0x00000500  ; GPIO 2-mA Drive Select (p428 datasheet de lm3s9B92.pdf)

; Digital enable register
; To use the pin as a digital input or output, the corresponding GPIODEN bit must be set.
GPIO_O_DEN  		EQU 	0x0000051C  ; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

LED1_BIT      EQU 0x10  ; bit 4 alone (binary 0001 0000)
LED2_BIT      EQU 0x20  ; bit 5 alone
	
	
		AREA    |.text|, CODE, READONLY
		ENTRY
		
		EXPORT LED_INIT
		EXPORT LED_CLIGNOTTEMENT
		EXPORT LED1_ON

			
LED_INIT
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION LED

        ldr r6, = GPIO_PORTF_BASE+GPIO_O_DIR    ;; 1 Pin du portF en sortie (broche 4 : 00010000)
        ldr r0, = BROCHE4_5 	
        str r0, [r6]
		
		ldr r6, = GPIO_PORTF_BASE+GPIO_O_DEN	;; Enable Digital Function 
        ldr r0, = BROCHE4_5		
        str r0, [r6]
		
		ldr r6, = GPIO_PORTF_BASE+GPIO_O_DR2R	;; Choix de l'intensité de sortie (2mA)
        ldr r0, = BROCHE4_5			
        str r0, [r6]
		
		mov r2, #0x000       					;; pour eteindre LED
     
		; allumer la led broche 4 (BROCHE4_5)
		mov r3, #BROCHE4_5		;; Allume LED1&2 portF broche 4&5 : 00110000
		
		ldr r6, = GPIO_PORTF_BASE + (BROCHE4_5<<2)  ;; @data Register = @base + (mask<<2) ==> LED1
		;vvvvvvvvvvvvvvvvvvvvvvvFin configuration LED 
		BX	LR	; FIN du sous programme d'init.
		
    
LED1_ON
        ; r6 will hold the address of the masked Port F Data register for bit 4.
        ;    "Masked" address = GPIO_PORTF_BASE + (bit_mask << 2).
        ldr   r6, =GPIO_PORTF_BASE + (LED1_BIT << 2)
        
        ; r0 will hold the value we want to write (0x10).
        mov   r0, #LED1_BIT
        
        ; Write to the masked register => turns PF4 on.
        str   r0, [r6]
        
        ; Return
        BX    LR



LED_CLIGNOTTEMENT
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CLIGNOTTEMENT

		str r3, [r6]  							;; Allume LED1&2 portF broche 4&5 : 00110000 (contenu de r3)

ReadState

		ldr r10,[r7]
		CMP r10,#0x00
		BNE ReadState

loop
        str r2, [r6]    						;; Eteint LED car r2 = 0x00      
        ldr r1, = DUREE 						;; pour la duree de la boucle d'attente1 (wait1)

wait1	subs r1, #1
        bne wait1

        str r3, [r6]  							;; Allume LED1&2 portF broche 4&5 : 00110000 (contenu de r3)
        ldr r1, = DUREE							;; pour la duree de la boucle d'attente2 (wait2)

wait2   subs r1, #1
        bne wait2

        b loop       
		
		BX	LR	; FIN du sous programme d'init.
		
		nop
		END