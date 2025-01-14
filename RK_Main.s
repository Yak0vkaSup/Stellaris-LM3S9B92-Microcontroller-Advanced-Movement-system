	;; RK - Evalbot (Cortex M3 de Texas Instrument)
	;; Les deux LEDs sont initialement allumées
	;; Ce programme lis l'état du bouton poussoir 1 connectée au port GPIOD broche 6
	;; Si bouton poussoir fermé ==> fait clignoter les deux LED1&2 connectée au port GPIOF broches 4&5.
   	
		AREA    |.text|, CODE, READONLY
 
; This register controls the clock gating logic in normal Run mode
SYSCTL_PERIPH_GPIO EQU		0x400FE108	; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf)

QEI0_BASE EQU 0x4002C000 ; right
QEI1_BASE EQU 0x4002D000 ; left
QEIPOS_OFFSET EQU 0x008

PWM_BASE		EQU		0x040028000 
PWM0CMPA		EQU		PWM_BASE+0x058
PWM1CMPA		EQU		PWM_BASE+0x098
	
	  	ENTRY
		EXPORT	__main
			
		IMPORT LED_INIT
		IMPORT LED_CLIGNOTTEMENT
		IMPORT BOUTON_INIT
			
			
        IMPORT MOTEUR_INIT
        IMPORT MOTEUR_DROIT_ON
        IMPORT MOTEUR_DROIT_OFF
        IMPORT MOTEUR_DROIT_AVANT
        IMPORT MOTEUR_DROIT_ARRIERE
        IMPORT MOTEUR_GAUCHE_ON
        IMPORT MOTEUR_GAUCHE_OFF
        IMPORT MOTEUR_GAUCHE_AVANT
        IMPORT MOTEUR_GAUCHE_ARRIERE
        IMPORT MOTEUR_DROIT_INVERSE
        IMPORT MOTEUR_GAUCHE_INVERSE
		IMPORT MOTEUR_STATE
		IMPORT LED1_ON
		;IMPORT LED2_ON
		IMPORT ENCODER_INIT
		IMPORT INTERRUPT_INIT
		IMPORT INTERRUPT_HANDLER_0
		IMPORT INTERRUPT_HANDLER_1
		
		
__main

        ; 1) Enable the Port D & F clocks as you already do:
        ldr r6, =0x400FE108          ; SYSCTL_RCGC2
        mov r0, #0x28                ; (0b101000) => Enable clocks on GPIO D & F
        str r0, [r6]
        nop
        nop
        nop
		
        ; 2) Initialize your hardwar
        BL BOUTON_INIT
        BL LED_INIT
        BL MOTEUR_INIT   ; sets up PWM hardware but doesn't turn motors ON yet

		BL ENCODER_INIT
		BL INTERRUPT_INIT
		;BL INTERRUPT_HANDLER_0
		;BL INTERRUPT_HANDLER_1
		
		
		BL MOTEUR_GAUCHE_AVANT ; pos -> bigger
		BL MOTEUR_DROIT_ARRIERE   
		
		ldr r5, = QEI0_BASE+QEIPOS_OFFSET ; right
		mov r0, #0
		str	r0,[r5]
		
		ldr r6, = QEI1_BASE+QEIPOS_OFFSET ; left 
		mov r1, #0
		str r1, [r6]
		
		ldr	r6, =PWM0CMPA 
		mov	r0, #0x199
		str	r0, [r6]  
		
		ldr	r6, =PWM1CMPA 
		mov	r0,	#0x199
		str	r0, [r6] 
		
		;BL LED2_ON
		
loop	
		BL	MOTEUR_DROIT_ON
		BL	MOTEUR_GAUCHE_ON
		
		ldr r5, = QEI0_BASE+QEIPOS_OFFSET ; right
		ldr r0, [r5]
		
		RSB r2, r0, #0x60
		CMP r2, #0x5 
		BLLT PWM_CONFIG_GT5
		BLGT PWM_CONFIG_GT20

		CMP r0, #0x60 ; 4 ticks per hole, 8 holes, 32 * 3 => 96 decimal => 60hexa
		BLLT MOTEUR_DROIT_AVANT ; Branch if Less Than (N = 1)
		BLEQ MOTEUR_DROIT_OFF     ; Branch if Equal (Z = 1)
		BLGT MOTEUR_DROIT_ARRIERE  ; Branch if Greater Than (N = 0 and Z = 0) 
		

		ldr r6, = QEI1_BASE+QEIPOS_OFFSET ; left 
		ldr r0, [r6]
		
		RSB r1, r0, #0x60
		CMP r1, #0x5 
		BLLT PWM_CONFIG_GT5
		BLGT PWM_CONFIG_GT20

		CMP r0, #0x60 ; 4 ticks per hole, 8 holes, 32 * 3 => 96 decimal => 60hexa
		BLLT MOTEUR_GAUCHE_AVANT; Branch if Less Than (N = 1)
		BLEQ MOTEUR_GAUCHE_OFF     ; Branch if Equal (Z = 1)
		BLGT MOTEUR_GAUCHE_ARRIERE; Branch if Greater Than (N = 0 and Z = 0) 
		
		B loop

PWM_CONFIG_GT5
		ldr	r6, =PWM0CMPA 
		mov	r3, #0x500
		str	r3, [r6]  
		
		ldr	r6, =PWM1CMPA 
		mov	r3,	#0x500
		str	r3, [r6] 
		
		bx lr
		
PWM_CONFIG_GT20
		ldr	r6, =PWM0CMPA 
		mov	r3, #0x199
		str	r3, [r6]  
		
		ldr	r6, =PWM1CMPA 
		mov	r3,	#0x199
		str	r3, [r6] 
		
		bx lr
		

		