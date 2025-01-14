RCGC1_BASE	EQU	0x400FE000
	
PORTC_BASE EQU 0x40006000
PORTE_BASE EQU 0x40024000
PORTG_BASE EQU 0x40026000

GPIOPCTL_OFFSET EQU 0x52C
GPIOAFSEL_OFFSET EQU 0x420
; STEP 5
QEICTL_OFFSET EQU 0x000
	
QEI0_BASE EQU 0x4002C000 ; right
QEI1_BASE EQU 0x4002D000 ; left
	
QEIMAXPOS_OFFSET EQU 0x00C

; STEP 7
QEIPOS_OFFSET EQU 0x008

QEILOAD_OFFSET EQU 0x010

GPIODATA_OFFSET EQU 0x000
GPIODIR_OFFSET EQU 0x400
GPIODR2R_OFFSET EQU 0x500
GPIODEN_OFFSET EQU 0x51C
	
PORTD_BASE		EQU		0x40007000
GPIODIR_D		EQU		PORTD_BASE+GPIODIR_OFFSET

SYSCTL_RCGC0	EQU		0x400FE100		;SYSCTL_RCGC0: offset 0x100 (p271 datasheet de lm3s9b92.pdf)
SYSCTL_RCGC1	EQU		0x400FE104
SYSCTL_RCGC2	EQU		0x400FE108		;SYSCTL_RCGC2: offset 0x108 (p291 datasheet de lm3s9b92.pdf)

	
mask_pin6 EQU 0x40
	
		AREA    |.text|, CODE, READONLY
		ENTRY
		
		EXPORT ENCODER_INIT

ENCODER_INIT
	;ldr r6, = SYSCTL_RCGC0
	;ldr	r0, [R6]
	;ORR	r0, r0, #0x00100000  ;;bit 20 = PWM recoit clock: ON (p271) 
	;str r0, [r6]
	
	; STEP 1 turn on qei clock
	ldr r6, = SYSCTL_RCGC1 
	ldr	r0, [R6]
	ORR	r0, r0, #0x300
	str r0, [r6]

	;STEP 2
	ldr r6, = SYSCTL_RCGC2
	ldr	r0, [R6]
	ORR	r0, r0, #0x54 ; E C AND G
	str r0, [r6]

	
	nop
	nop
	nop
	
	; TURN ON switch
	
	ldr r6, = PORTE_BASE+GPIODIR_OFFSET
	ldr r0, = mask_pin6
	str r0, [r6]
	
	ldr r6, = PORTE_BASE+GPIODEN_OFFSET
	ldr	r0, = mask_pin6
	str r0, [r6]
	
	ldr r6, = PORTE_BASE+(mask_pin6<<2)
	mov r0, mask_pin6
	str r0, [r6]
	
	; DEN 
	
	

	ldr r6, = PORTE_BASE+GPIODEN_OFFSET
	ldr	r0, [R6]
	ORR	r0, r0, #0xC
	str r0, [r6]
	
	ldr r6, = PORTC_BASE+GPIODEN_OFFSET
	ldr	r0, [R6]
	ORR	r0, r0, #0x80
	str r0, [r6]
	
	ldr r6, = PORTG_BASE+GPIODEN_OFFSET
	ldr	r0, [R6]
	ORR	r0, r0, #0x80
	str r0, [r6]


	; STEP 3
	ldr r6, = PORTE_BASE+GPIOAFSEL_OFFSET
	ldr	r0, [R6]
	ORR	r0, r0, #0xC
	str r0, [r6]

	ldr r6, = PORTC_BASE+GPIOAFSEL_OFFSET
	ldr	r0, [R6]
	ORR	r0, r0, #0x80
	str r0, [r6]

	
	ldr r6, = PORTG_BASE+GPIOAFSEL_OFFSET
	ldr	r0, [R6]
	ORR	r0, r0, #0x80
	str r0, [r6]
	
	; STEP 4
	
	ldr r6, = PORTC_BASE+GPIOPCTL_OFFSET
	ldr	r0, [R6]
	ORR	r0, r0, #0x20000000
	str r0, [r6]
	
	ldr r6, = PORTE_BASE+GPIOPCTL_OFFSET
	ldr	r0, [R6]
	ORR	r0, r0, #0x3400
	str r0, [r6]
	
	ldr r6, = PORTG_BASE+GPIOPCTL_OFFSET
	ldr	r0, [R6]
	ORR	r0, r0, #0x10000000
	str r0, [r6]
	
	; velocity timer
	ldr r6, = QEI0_BASE+QEILOAD_OFFSET
	ldr  r0, = 0xF423FF ; 16MHZ-1
	str r0, [r6]
	  
	ldr r6, = QEI1_BASE+QEILOAD_OFFSET
	ldr  r0, = 0xF423FF ; 16MHZ-1
	str r0, [r6]
	
	; STEP 5 

	ldr r6, = QEI0_BASE+QEIMAXPOS_OFFSET
	mov r0, #0xFFFFFFFF ; MAX VALUE
	str r0, [r6] 
	
	ldr r6, = QEI0_BASE+QEICTL_OFFSET
	mov r0, #0x2029 ;
	str r0, [r6]
	
	; STEP 6
	;ldr r6, = QEI0_BASE+QEICTL_OFFSET
	;ldr	r0, [R6]
	;ORR	r0, r0, #0x1
	;str r0, [r6]
	
	
	; QEI 1
	ldr r6, = QEI1_BASE+QEIMAXPOS_OFFSET
	mov r0, #0xFFFFFFFF ; MAX VALUE
	str r0, [r6] 
	
	ldr r6, = QEI1_BASE+QEICTL_OFFSET
	mov r0, #0x2029
	str r0, [r6]
	
	
	; STEP 6
	;ldr r6, = QEI1_BASE+QEICTL_OFFSET
	;ldr	r0, [R6]
	;ORR	r0, r0, #0x1
	;str r0, [r6]
	
	
	;ldr r6, = QEI0_BASE+QEIPOS_OFFSET
	

;loop
	;ldr r0, [r6]
	;b loop
	
	BX LR
