	INCLUDE Macros_Utilities.s
	
	AREA MyData, DATA, READONLY
	
SPI1_BASE		EQU		0x40013000
SPI1_CR1		EQU     SPI1_BASE+0x00
SPI1_CR2		EQU     SPI1_BASE+0x04	
SPI1_SR			EQU		SPI1_BASE+0x08
SPI1_DR	    	EQU		SPI1_BASE+0x0C
SPI1_CRCPR		EQU		SPI1_BASE+0x10
SPI1_RXCRCR		EQU		SPI1_BASE+0x14
SPI1_TXCRCR		EQU		SPI1_BASE+0x18
SPI1_I2SCFGR	EQU		SPI1_BASE+0x1C
SPI1_I2SPR	    EQU		SPI1_BASE+0x20
	
	
; in port A	
MOSI_PIN	EQU		7
MISO_PIN	EQU		6
SCK_PIN		EQU		5
CS_PIN		EQU		4
	
	
	AREA MyCode, CODE, READONLY
		
		
		
SPI_INIT

	PUSH {R0-R12, LR}			; Push all GPRs and Link Register (LR) onto the stack

	LDR R0, =RCC_APB2ENR
	MOV R3, #12			; SPI 1 clock enable
	BL setBit

	;;;;;;;; SPI pins configurations ;;;;;;;
	
	LDR R0, =GPIOA_CRL
	LDR R1, [R0]
	MOV R2, #0xF				; specifying four bits to clear
	MOV R3, #(4*CS_PIN)
	BL clearMultiBits
	MOV R2, #0x3				; specifying the bits to set
	MOV R3, #(4*CS_PIN)
	BL setMultiBits
	
	; Configure PA5 (SCK) as Alternate Function Push-Pull Output 50Hz
	LDR R0, =GPIOA_CRL
	LDR R1, [R0]
	MOV R2, #0xF				; specifying four bits to clear
	MOV R3, #(4*SCK_PIN)
	BL clearMultiBits
	MOV R2, #0xB				; specifying the bits to set
	MOV R3, #(4*SCK_PIN)
	BL setMultiBits
	
	; Configure PA6 (MISO) as Input Pull down
	LDR R0, =GPIOA_CRL
	MOV R2, #0xF				; specifying four bits to clear
	MOV R3, #(4*MISO_PIN)
	BL clearMultiBits
	MOV R2, #0x8				; specifying the bits to set
	MOV R3, #(4*MISO_PIN)
	BL setMultiBits
	
	; Configure PA7 (MOSI) as Alternate Function Push-Pull Output 50Hz
	LDR R0, =GPIOA_CRL
	MOV R2, #0xF				; specifying four bits to clear
	MOV R3, #(4*MOSI_PIN)
	BL clearMultiBits
	MOV R2, #0xB				; specifying the bits to set
	MOV R3, #(4*MOSI_PIN)
	BL setMultiBits
	
	;;;;;;;;; SPI configurations ;;;;;;;;;;
	LDR R0, =SPI1_CR1
	MOV R3, #2			; controller is master
	BL setBit
		
	LDR R0, =SPI1_CR1
	MOV R2, #0x7
	MOV R3, #3
	BL clearMultiBits
	MOV R2, #0x0		; number of bits 3 =0b11 means 3 bits to be sit
	MOV R3, #3			;index of first bit
	BL setMultiBits
	
	;LDR R0, =SPI1_CR1
	;MOV R3, #11			; b-bit data frame selected 8-bits
	;BL clearBit

	;LDR R0, =SPI1_CR1
	;MOV R3, #1			; clock polarity set to zero (low when idle)	
	;BL clearBit
	
	;LDR R0, =SPI1_CR1
	;MOV R3, #0  		; clock phase set to zero sending at first edge (from idle to active)	
	;BL clearBit
	
	;LDR R0, =SPI1_CR1
	;MOV R3, #7			; sending MSB (most segnificant bit) first
	;BL clearBit
	
	LDR R0, =SPI1_CR2
	MOV R3, #2
	BL setBit
	
	LDR R0, =SPI1_CR1
	MOV R3, #6			; SPI peripheral enabled
	BL setBit
	
	BL delay_half_second
	
	LDR R0, =GPIOA_ODR
	MOV R3, #CS_PIN
	BL setBit
	
	
    POP {R0-R12, PC}                ; Pop R4 and return from subroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


SPI_SEND

	PUSH{R0-R12, LR}
	
	LDR R0, = SPI1_SR
	MOV R3, #3						; watit for the Tx/sending buffer is embty
	BL waitFlagClears

	LDR R0, =SPI1_DR
	STR R2, [R0]					; store the data to be sent
	
	
	LDR R0, =SPI1_SR
	MOV R3, #7						; wait for the SPI to finish sending data (no longer busy)
	BL waitFlagClears
		
	LDR R0, [R0]
	
	POP{R0-R12, PC}
	