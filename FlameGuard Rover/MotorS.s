	AREA    MYDAT, DATA, READONLY

;##########################ADDRESSES##############################;
GPIOA_BASE 	EQU		  0x40010800       ; Base address of GPIOA
GPIOA_BSRR	EQU		GPIOA_BASE + 0x10 ; Address for GPIOA Bit Set/Reset Register
GPIOA_BRR   EQU		GPIOA_BASE + 0x14 ; Address for GPIOA Bit Reset Register
	
DELAY_INTERVAL 	EQU 0x186004        ; Constant delay value for approx. 1 second

    AREA MyCode, CODE, READONLY

;##########################EXPORT##############################;
	EXPORT MOVE_FORWARD        ; Export function to move car forward
	EXPORT MOVE_RIGHT          ; Export function to turn car right
	EXPORT MOVE_LEFT           ; Export function to turn car left
	EXPORT MOVE_BACKWARD       ; Export function to move car backward
	EXPORT STOP_CAR            ; Export function to stop car movement
	EXPORT DELAY_10SEC         ; Export function to delay for 10 seconds
	EXPORT delay_1_second      ; Export function to delay for 1 second

;##########################FUNCTIONS##############################;

MOVE_FORWARD 
	push {R0-R12,LR}           ; Save all general-purpose registers and LR
	LDR R0, =GPIOA_BRR         ; Load address of BRR register
	MOV R1, #0xF               ; Clear all motor control bits
	STR R1, [R0]               ; Write to BRR
	LDR R0, =GPIOA_BSRR        ; Load address of BSRR register
	MOV R1, #0xA               ; Set bits 1 and 3 for forward movement
	STR R1, [R0]               ; Write to BSRR
	pop {R0-R12,PC}            ; Restore registers and return

MOVE_RIGHT 
	push {R0-R12,LR}           
	LDR R0, =GPIOA_BRR         
	MOV R1, #0xF               ; Clear all motor control bits
	STR R1, [R0]               
	LDR R0, =GPIOA_BSRR        
	MOV R1, #0x02              ; Set bit 1 for right turn
	STR R1, [R0]               
	pop {R0-R12,PC}            

MOVE_LEFT 
	push {R0-R12,LR}           
	LDR R0, =GPIOA_BRR         
	MOV R1, #0xF               ; Clear all motor control bits
	STR R1, [R0]               
	LDR R0, =GPIOA_BSRR        
	MOV R1, #0x08              ; Set bit 3 for left turn
	STR R1, [R0]               
	pop {R0-R12,PC}            

MOVE_BACKWARD 
	push {R0-R12,LR}           
	LDR R0, =GPIOA_BRR         
	MOV R1, #0xF               ; Clear all motor control bits
	STR R1, [R0]               
	LDR R0, =GPIOA_BSRR        
	MOV R1, #0x5               ; Set bits 0 and 2 for backward movement
	STR R1, [R0]               
	pop {R0-R12,PC}            

STOP_CAR 
	push {R0-R12,LR}           
	LDR R0, =GPIOA_BRR         
	MOV R1, #0xFF              ; Reset all GPIOA pins (stop all motors)
	STR R1, [R0]               
	pop {R0-R12,PC}            

delay_1_second
	; This function creates approximately a 1-second delay
	PUSH {R8, LR}              ; Save R8 and LR
	LDR r8, =DELAY_INTERVAL    ; Load delay interval constant
delay_loop
	SUBS r8, #1                ; Decrement counter
	CMP r8, #0                 ; Compare with 0
	BGE delay_loop             ; Loop until counter reaches 0
	POP {R8, PC}               ; Restore R8 and return

DELAY_10SEC
	push {R0-R12,LR}           ; Save registers
	MOV R9, #20                ; Loop 20 times (20 * 0.5s ˜ 10s assuming each delay is ~0.5s)
DELAY_10SEC_LOOP
	BL delay_1_second          ; Call 1 second delay
	SUBS R9, #1                ; Decrement loop counter
	CMP R9, #0                 ; Compare with 0
	BGE DELAY_10SEC_LOOP       ; Loop until counter reaches 0
	pop {R0-R12,PC}            ; Restore registers and return
