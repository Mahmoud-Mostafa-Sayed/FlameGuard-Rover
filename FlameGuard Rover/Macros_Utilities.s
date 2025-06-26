	AREA MyData, DATA, READONLY
	
RCC_BASE	EQU		0x40021000
;RCC_AHB1ENR EQU 0x40023830 ;this register is responsible for enabling certain ports, by making the clock affect the target port.
RCC_APB2ENR		EQU		RCC_BASE + 0x18
	
	
GPIOA_BASE		EQU		0x40010800   ; port A
GPIOA_CRL		EQU		GPIOA_BASE+0x00
GPIOA_CRH		EQU		GPIOA_BASE+0x04
GPIOA_ODR		EQU		GPIOA_BASE+0x0C
GPIOA_IDR		EQU		GPIOA_BASE+0x08	

GPIOB_BASE		EQU		0x40010C00   ; port B
GPIOB_CRL		EQU		GPIOB_BASE+0x00
GPIOB_CRH		EQU		GPIOB_BASE+0x04
GPIOB_ODR		EQU		GPIOB_BASE+0x0C
GPIOB_IDR		EQU		GPIOB_BASE+0x08
	
	
INTERVAL EQU 0x186004		;just a number to perform the delay. this number takes roughly 1 second to decrement until it reaches 0

	
	AREA MyCode, CODE, READONLY


Divide
	;PUSH {R0-R7, LR}			; Push all GPRs and Link Register (LR) onto the stack
	;R8: Dividend
	;R9: Divisor
	;R8: Remainder
	;R9: Quotient

    CMP R9, #0          ; Check if divisor is 0
    BEQ DivisionByZero  ; Branch to error handler if divisor is 0

    MOV R11, #0          ; Initialize quotient (R3) to 0

DivideLoop
    CMP R8, R9          ; Compare dividend with divisor
    BLT Done            ; If dividend < divisor, division is complete

    SUB R8, R9      ; Subtract divisor from dividend
    ADD R11, #1      ; Increment quotient

    B DivideLoop        ; Repeat until dividend < divisor

Done
    MOV R9, R11          ; R3 now holds the remainder
    BX LR               ; Return to caller
	;POP {R0-R7, PC}			; Pop to all GPRs and return from subroutine

DivisionByZero
    MOV R8, #0          ; Set quotient to 0
    MOV R9, #0          ; Set remainder to 0
	;POP {R0-R7, PC}			; Pop to all GPRs and return from subroutine
    BX LR               ; Return to caller


;#################################################################################################################################


waitFlagSets FUNCTION
    PUSH {R0-R12, LR}			; Push all GPRs and Link Register (LR) onto the stack
WaitSet
	LDR R1, [R0]				; Read the current value of the given mapped register
	MOV R2, #1					; Specify One Bit to Read
	LSL R2, R3					; Shift the bit needed to its location in register
	
	TST R1, R2					; check the value of the needed bit individually  (TST changes the flags as AND would without doint the actual operation)
	;AND R1, R2
	;CMP R1, #0
	
	BEQ WaitSet
	
	POP {R0-R12, PC}			; Pop to all GPRs and return from subroutine
	ENDFUNC
	
	
waitFlagClears FUNCTION
    PUSH {R0-R12, LR}			; Push all GPRs and Link Register (LR) onto the stack
WaitClear
	LDR R1, [R0]				; Read the current value of the given mapped register
	MOV R2, #1					; Specify One Bit to Read
	LSL R2, R3					; Shift the bit needed to its location in register
	
	TST R1, R2					; check the value of the needed bit individually  (TST changes the flags as AND would without doint the actual operation)
	;AND R1, R2
	;CMP R1, #0
	
	BNE WaitClear
	
	POP {R0-R12, PC}			; Pop to all GPRs and return from subroutine
	ENDFUNC
	



; Preceeding value (arguments):		R0= mapped register physical address, R3= the index/number of the bit you want to read in the register, R0= result returned	
readBit
    ;PUSH {R1-R12, LR}			; Push all GPRs and Link Register (LR) onto the stack

	LDR R4, [R0]				; Read the current value of the given mapped register
	MOV R2, #0x1				; Specify One Bit to Read
	LSL R2, R3					; Shift the bit needed to its location in register
	
	AND R4, R2					; Take the value of the needed bit individually
	
	MOV R0, R4
	
	PUSH {R0}
	BX LR
	;POP {R1-R12, PC}			; Pop to all GPRs and return from subroutine
	
	
; Preceeding value (arguments):		R0= mapped register physical address, R3= the index/number of the bit you want to read in the register, R0= result returned
;									, R2= the non-indexed bits needed to be read (e.g 0b111 for 3 bits) to be shifted to their index
readMultiBits
	PUSH {R1-R12, LR}			; Push all GPRs and Link Register (LR) onto the stack

	LDR R0, [R0]
	LSL R2, R3
	
	AND R0, R2

	BX LR
	;POP {R1-R12, PC}			; Pop to all GPRs and return from subroutine
	
	
		
; Preceeding value (arguments):		R0= mapped register physical address, R3= the index/number of the bit you want to set in the register		
setBit FUNCTION
    PUSH {R0-R12, LR}			; Push all GPRs and Link Register (LR) onto the stack
	
    LDR R1, [R0]				; Read the current value of the given mapped register
	MOV R2, #0x1				; Specify One Bit to Edit
	LSL R2, R3					; Shift the bit needed to its location in register
    ORR R1, R1, R2   		    ; set the needed bit to 1
    STR R1, [R0]				; Write the updated value back to the given mapped register
	
	POP {R0-R12, PC}			; Pop to all GPRs and return from subroutine
	ENDFUNC
	
; Preceeding value (arguments):		R0= mapped register physical address, R3= the index/number of the bit you want to set in the register
;									, R2= the non-indexed bits needed to be set (e.g 0b111 for 3 bits) to be shifted to their index
setMultiBits FUNCTION
    PUSH {R0-R12, LR}			; Push all GPRs and Link Register (LR) onto the stack
	
    LDR R1, [R0]				; Read the current value of the given mapped register
	LSL R2, R3
    ORR R1, R1, R2				; set the needed bit to 1s
    STR R1, [R0]				; Write the updated value back to RCC_APB2ENR
	
	POP {R0-R12, PC}                ; Pop R4 and return from subroutine
	ENDFUNC
	
	
; Preceeding value (arguments):		R0= mapped register physical address, R3= the index/number of the bit you want to clear in the register
clearBit FUNCTION
    PUSH {R0-R12, LR}			; Push all GPRs and Link Register (LR) onto the stack
	
    LDR R1, [R0]				; Read the current value of the given mapped register
	MOV R2, #0x1				; Specify One Bit to Edit
	
	LSL R2, R3					; Shift the bit needed to its location in register
	MVN R2, R2					; Get the complement value of the value
	
    AND R1, R1, R2				; Clear the needed bit to 0
	
    STR R1, [R0]				; Write the updated value back to the given mapped register
	
	POP {R0-R12, PC}			; Pop to all GPRs and return from subroutine
	ENDFUNC
	
; Preceeding value (arguments):		R0= mapped register physical address, R3= the index/number of the bit you want to clear in the register
;									, R2= the non-indexed bits needed to be clear (e.g 0b111 for 3 bits) to be shifted to their index
clearMultiBits FUNCTION
    PUSH {R0-R12, LR}			; Push all GPRs and Link Register (LR) onto the stack
	
    LDR R1, [R0]				; Read the current value of the given mapped register
	
	LSL R2, R3					; Shift the bits needed to its location in register
	MVN R2, R2					; Get the complement value of the value
	
    AND R1, R1, R2				; Clear the needed bits to 0s
	
    STR R1, [R0]				; Write the updated value back to the given mapped register
	
	POP {R0-R12, PC}			; Pop to all GPRs and return from subroutine
	ENDFUNC




;##########################################################################################################################################
delay_1_second
	;this function just delays for 1 second
	PUSH {R8, LR}
	LDR r8, =INTERVAL
delay_loop
	SUBS r8, #1
	CMP r8, #0
	BGE delay_loop
	POP {R8, PC}
;##########################################################################################################################################




;##########################################################################################################################################
delay_half_second
	;this function just delays for half a second
	PUSH {R8, LR}
	LDR r8, =INTERVAL
delay_loop1
	SUBS r8, #2
	CMP r8, #0
	BGE delay_loop1

	POP {R8, PC}
;##########################################################################################################################################
