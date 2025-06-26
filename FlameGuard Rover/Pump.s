	AREA    MYDAT, DATA, READONLY

;##########################ADDRESSES##############################;
GPIOB_BASE      EQU     0x40010C00        ; Base address of GPIOB
GPIOB_BSRR      EQU     GPIOB_BASE + 0x10 ; Address for GPIOB Bit Set/Reset Register
GPIOB_BRR       EQU     GPIOB_BASE + 0x14 ; Address for GPIOB Bit Reset Register

    AREA MyCode, CODE, READONLY

;##########################EXPORT##############################;
	EXPORT TURN_ON_PUMP        ; Export the function to turn on the pump
	EXPORT TURN_OFF_PUMP       ; Export the function to turn off the pump

;##########################FUNCTIONS##############################;

TURN_ON_PUMP
	push {R0-R12,LR}           ; Save all general-purpose registers and link register

	LDR R0, =GPIOB_BRR         ; Load address of GPIOB BRR (to clear pin)
	ORR R1, #(1<<9)            ; Set bit 9 in R1 (corresponding to PB9)
	STR R1, [R0]               ; Write to BRR to reset PB9

	LDR R0, =GPIOB_BSRR        ; Load address of GPIOB BSRR (to set pin)
	ORR R1, #(1<<9)            ; Set bit 9 in R1 (PB9 high)
	STR R1, [R0]               ; Write to BSRR to set PB9

	pop {R0-R12,PC}            ; Restore registers and return

TURN_OFF_PUMP
	push {R0-R12,LR}           ; Save all general-purpose registers and link register

	LDR R0, =GPIOB_BRR         ; Load address of GPIOB BRR
	ORR R1, #(1<<9)            ; Set bit 9 in R1 (PB9)
	STR R1, [R0]               ; Write to BRR to reset PB9 (turn off pump)

	pop {R0-R12,PC}            ; Restore registers and return