	AREA    MYDAT, DATA, READONLY

;##########################ADDRESSES##############################;
USART1_BASE    EQU  0x40013800            ; Base address of USART1
USART1_CR1     EQU  USART1_BASE + 0x0C    ; Control register 1 (enable TX, RX, USART)
USART1_BRR     EQU  USART1_BASE + 0x08    ; Baud rate register
USART1_SR      EQU  USART1_BASE + 0x00    ; Status register (contains TXE, RXNE flags)
USART1_DR      EQU  USART1_BASE + 0x04    ; Data register (for reading/writing data)

    AREA MyCode, CODE, READONLY

;##########################IMPORT##############################;
	IMPORT MOVE_FORWARD          ; Function to move car forward
	IMPORT MOVE_RIGHT            ; Function to turn car right
	IMPORT MOVE_LEFT             ; Function to turn car left
	IMPORT MOVE_BACKWARD         ; Function to move car backward
	IMPORT STOP_CAR              ; Function to stop the car
	IMPORT SET_PWM               ; Function to set PWM speed

;##########################EXPORT##############################;
	EXPORT Bluetooth_ReceiveLoop ; Exported function to handle Bluetooth input loop

;##########################FUNCTIONS##############################;

Bluetooth_ReceiveLoop
	PUSH    {LR, R0-R4}           ; Save registers for function call

BLUETOOTH_LOOP
	LDR     R4, =1071429          ; Load a timeout counter value

wait_loop
	LDR     R0, =USART1_SR        ; Load address of USART1 status register
	LDR     R1, [R0]              ; Read status register
	TST     R1, #0x20             ; Test RXNE (bit 5) to check if data is available
	BNE     data_received         ; If data received, branch to handler

	SUBS    R4, R4, #1            ; Decrease timeout counter
	BNE     wait_loop             ; Loop if not zero (wait until timeout or data arrives)

	; Timeout occurred — stop the car
	BL      STOP_CAR
	B       BLUETOOTH_LOOP        ; Restart listening loop

data_received
	; Data received from Bluetooth
	LDR     R0, =USART1_DR        ; Load address of data register
	LDRB    R2, [R0]              ; Read received byte into R2

	; Compare received byte to command characters
	CMP     R2, #'F'              ; Forward
	BEQ     call_forward
	CMP     R2, #'B'              ; Backward
	BEQ     call_backward
	CMP     R2, #'L'              ; Left
	BEQ     call_left
	CMP     R2, #'R'              ; Right
	BEQ     call_right
	CMP     R2, #'W'              ; Set speed to 300
	BEQ     SPEED1
	CMP     R2, #'w'              ; Set speed to 500
	BEQ     SPEED2
	CMP     R2, #'U'              ; Set speed to 800
	BEQ     SPEED3
	CMP     R2, #'u'              ; Set speed to 1000
	BEQ     SPEED4
	CMP     R2, #'V'              ; Exit
	BEQ     call_exit

	B       BLUETOOTH_LOOP        ; Unrecognized input — loop again

call_forward 
	BL      MOVE_FORWARD          ; Call move forward function
	B       BLUETOOTH_LOOP

call_backward
	BL      MOVE_BACKWARD         ; Call move backward function
	B       BLUETOOTH_LOOP

call_left
	BL      MOVE_LEFT             ; Call move left function
	B       BLUETOOTH_LOOP

call_right 
	BL      MOVE_RIGHT            ; Call move right function
	B       BLUETOOTH_LOOP
	
SPEED1
	MOV     R1, #300              ; Set PWM speed to 300
	BL      SET_PWM
	B       BLUETOOTH_LOOP

SPEED2
	MOV     R1, #500              ; Set PWM speed to 500
	BL      SET_PWM
	B       BLUETOOTH_LOOP
	
SPEED3
	MOV     R1, #800              ; Set PWM speed to 800
	BL      SET_PWM
	B       BLUETOOTH_LOOP

SPEED4
	MOV     R1, #1000             ; Set PWM speed to 1000
	BL      SET_PWM
	B       BLUETOOTH_LOOP

call_exit
	BL      STOP_CAR              ; Stop car before exiting
	POP     {LR, R0-R4}           ; Restore registers
	BX      LR                    ; Return from function