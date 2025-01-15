
; see page 109
EN0 EQU 0xE000E100 ; page 136-137 number 13
EN1 EQU 0xE000E104
	
QEI0_BASE EQU 0x4002C000 ; right
QEI1_BASE EQU 0x4002D000 ; left

GPIO_PORTF_BASE		EQU		0x40025000
GPIO_PORTD_BASE		EQU		0x40007000	
	
LED1_BIT      EQU 0x10 
LED2_BIT      EQU 0x20 

QEIISC_OFFSET EQU 0x028
GPIOMIS_OFFSET EQU 0x418
QEIINTEN_OFFSET EQU 0x020 
GPIOICR_OFFSET EQU 0x41C

QEIPOS_OFFSET EQU 0x008
PWM_BASE		EQU		0x040028000 
PWM0CMPA		EQU		PWM_BASE+0x058
PWM1CMPA		EQU		PWM_BASE+0x098

		AREA    |.text|, CODE, READONLY
		ENTRY
		
		EXPORT INTERRUPT_INIT
		EXPORT INTERRUPT_HANDLER_0
		EXPORT INTERRUPT_HANDLER_1
		EXPORT PORTD_INTERRUPT_HANDLER
		IMPORT main_loop
		IMPORT loop2
			
INTERRUPT_INIT

	ldr r6, = EN0
	mov r0, #0x2008
	str r0, [r6]
	
	ldr r6, = EN1
	mov r0, #0x40 ; 32 - 36 page 137
	str r0, [r6]
	
	;ldr r6, = QEI0_BASE+QEIINTEN_OFFSET
	;mov r0, #0x2
	;str r0, [r6]
	
	ldr r6, = QEI1_BASE+QEIINTEN_OFFSET
	mov r0, #0x2
	str r0, [r6]
	
	
	BX LR

PORTD_INTERRUPT_HANDLER
    ldr r1, = GPIO_PORTD_BASE + GPIOMIS_OFFSET  
    ldr r0, [r1]                              
    
    cbz r0, exit_portd_handler                 ; Exit if no interrupt is active

    tst r0, #0x40                              ; Check PD6 
    bne handle_top_button                      

    tst r0, #0x80                              ; Check PD7
    bne handle_bottom_button                

exit_portd_handler
    bx lr                                      

handle_top_button
    ldr r2, = GPIO_PORTD_BASE + GPIOICR_OFFSET 
    mov r0, #0x40                              
    str r0, [r2]

    ldr r3, = GPIO_PORTF_BASE + (LED1_BIT << 2)
    ldr r0, [r3]
    eor r0, r0, #LED1_BIT                      
    str r0, [r3]

    b exit_portd_handler                    

handle_bottom_button
    ldr r2, = GPIO_PORTD_BASE + GPIOICR_OFFSET 
    mov r0, #0x80                              
    str r0, [r2]

    ldr r3, = GPIO_PORTF_BASE + (LED1_BIT << 2)
    ldr r0, [r3]
    eor r0, r0, #LED1_BIT                  
    str r0, [r3]

    b exit_portd_handler                   

	
INTERRUPT_HANDLER_0

	ldr r1, = QEI0_BASE+QEIISC_OFFSET
	;nop
	ldr r0, [r1] ;architecture defect, the execution is faster than interrupt that NVIC has no 
	;time to remove a flag and we add one additional reading to fix that
	cbz r0, exit_handler_0 ; if r0 is 0, so no flag we just exit
	mov r0, #0x2
	str r0, [r1]
	
	ldr   r2, =GPIO_PORTF_BASE + (LED1_BIT << 2)
	ldr   r0, [r2]
	eor r0, r0, #LED1_BIT
	str   r0, [r2]
exit_handler_0
	BX LR
	
INTERRUPT_HANDLER_1
	ldr r1, = QEI1_BASE+QEIISC_OFFSET
	;nop
	ldr r0, [r1] ;architecture defect, the execution is faster than interrupt that NVIC has no 
	;time to remove a flag and we add one additional reading to fix that*
	cbz r0, exit_handler_1 
	mov r0, #0x2
	str r0, [r1]
	
	ldr   r3, =GPIO_PORTF_BASE + (LED2_BIT << 2)
	ldr   r0, [r3]
	eor r0, r0, #LED2_BIT
	str   r0, [r3]
exit_handler_1
	BX LR
	
