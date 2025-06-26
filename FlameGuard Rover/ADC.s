	INCLUDE SPI.s
	
 
		
ADC1_BASE		EQU		0x40012400
ADC1_CR2		EQU		ADC1_BASE+0x08
ADC1_SR			EQU		ADC1_BASE+0x00
ADC1_SQR1		EQU		ADC1_BASE+0x2c
ADC1_SQR3		EQU		ADC1_BASE+0x34
ADC1_SMPR2		EQU		ADC1_BASE+0x10
ADC1_DR			EQU		ADC1_BASE+0x4c
	
	
	AREA MyCode, CODE, READONLY
		

ADC_INIT
    PUSH {R0-R12, LR}			; Push all GPRs and Link Register (LR) onto the stack
	
	LDR R0, =RCC_APB2ENR
	MOV R3, #9			; ADC 1 clock enable
	BL setBit
	
	LDR R0, =GPIOA_CRL			; putting PA0 as analog input
	LDR R2, =0x0F
	LDR R3, =(4*0)
	BL clearMultiBits
	
	LDR R0, =GPIOA_CRL			; putting PA1 as analog input
	LDR R2, =0x0F
	LDR R3, =(4*0)
	BL clearMultiBits
	
	LDR R0, =ADC1_CR2
	MOV R3, #0					; enabling ADC by setting ADON
	BL setBit

	BL delay_1_second
	
	LDR R0, =ADC1_CR2
	MOV R3, #3					; setting CALRST to reset callibration
	BL setBit
	
	BL waitFlagClears
	
	;;;;; configurations ;;;;
	
	
	LDR R0, =ADC1_SQR3
	MOV R1, #0					; storing 0 on SQR3 specifying channel 0
	STR R1, [R0]
	
	LDR R0, =ADC1_SQR1
	MOV R1, #0					; storing 0 on SQR1 specifying 1 conversion to be done
	STR R1, [R0]
	
	LDR R0, =ADC1_SMPR2
	MOV R1, #0x7				; storing three 1s in SMPR2 specifying max sample time for channel 0
	STR R1, [R0]
	
	LDR R0, =ADC1_CR2
	MOV R1, #1					; clearing CONT for single conversion
	BL clearBit
	
	POP {R0-R12, PC}			; Pop to all GPRs and return from subroutine
	
	

ADCval1
    PUSH {R0-R10, LR}			; Push all GPRs and Link Register (LR) onto the stack
	
	LDR R0, =ADC1_CR2
	MOV R3, #1					; clearing CONT for single conversion
	BL clearBit

	LDR R0, =ADC1_CR2
	MOV R3, #22				; start conversion by setting SWSTART
	BL setBit
	
	LDR R0, =ADC1_SR
	MOV R3, #1					; waiting for EOC to clear (conversion ends)
	BL waitFlagSets
	
	LDR R0, =ADC1_DR
	LDR R11, [R0]				; store the ADC value in R11
	
	POP {R0-R10, PC}			; Pop to all GPRs and return from subroutine
	
	
ADCval2
    PUSH {R0-R10, LR}			; Push all GPRs and Link Register (LR) onto the stack
	
	LDR R0, =ADC1_CR2
	MOV R3, #1					; clearing CONT for single conversion
	BL clearBit

	LDR R0, =ADC1_CR2
	MOV R3, #22				; start conversion by setting SWSTART
	BL setBit
	
	LDR R0, =ADC1_SR
	MOV R3, #1					; waiting for EOC to clear (conversion ends)
	BL waitFlagSets
	
	LDR R0, =ADC1_DR
	LDR R11, [R0]				; store the ADC value in R11
	
	POP {R0-R10, PC}			; Pop to all GPRs and return from subroutine
	