	AREA MYDATA, DATA, READONLY
	THUMB		

;########################## PERIPHERAL BASE ADDRESSES ##########################;
RCC_BASE	    EQU 0x40021000 
RCC_APB2ENR     EQU RCC_BASE + 0x018      ; APB2 peripheral clock enable
RCC_APB1ENR     EQU RCC_BASE + 0x1C       ; APB1 peripheral clock enable

GPIOA_BASE 	    EQU 0x40010800 
GPIOA_MODERL    EQU GPIOA_BASE + 0x00     ; GPIOA low mode config
GPIOA_MODERH    EQU GPIOA_BASE + 0x04     ; GPIOA high mode config
GPIOA_ODR	    EQU GPIOA_BASE + 0x0C     ; GPIOA output data register
GPIOA_IDR	    EQU GPIOA_BASE + 0x08     ; GPIOA input data register
GPIOA_BSRR	    EQU GPIOA_BASE + 0x10     ; GPIOA bit set/reset register
GPIOA_BRR       EQU GPIOA_BASE + 0x14     ; GPIOA bit reset register

GPIOB_BASE      EQU 0x40010C00
GPIOB_CRL       EQU GPIOB_BASE + 0x00     ; GPIOB low mode config
GPIOB_CRH       EQU GPIOB_BASE + 0x04     ; GPIOB high mode config
GPIOB_IDR       EQU GPIOB_BASE + 0x08     ; GPIOB input data register
GPIOB_ODR       EQU GPIOB_BASE + 0x0C     ; GPIOB output data register
GPIOB_BSRR	    EQU GPIOB_BASE + 0x10     ; GPIOB bit set/reset register
GPIOB_BRR       EQU GPIOB_BASE + 0x14     ; GPIOB bit reset register

USART1_BASE     EQU 0x40013800
USART1_CR1      EQU USART1_BASE + 0x0C    ; USART1 control register 1
USART1_BRR      EQU USART1_BASE + 0x08    ; USART1 baud rate register
USART1_SR       EQU USART1_BASE + 0x00    ; USART1 status register
USART1_DR       EQU USART1_BASE + 0x04    ; USART1 data register

AFIO_BASE       EQU 0x40010000
AFIO_MAPR       EQU AFIO_BASE + 0x04      ; AFIO remap register

;########################## TIMER BASE ADDRESSES ##########################;
TIM2_BASE       EQU 0x40000000
TIM2_CR1        EQU TIM2_BASE + 0x00
TIM2_CCMR1      EQU TIM2_BASE + 0x18
TIM2_CCER       EQU TIM2_BASE + 0x20
TIM2_PSC        EQU TIM2_BASE + 0x28
TIM2_ARR        EQU TIM2_BASE + 0x2C
TIM2_CCR1       EQU TIM2_BASE + 0x34      ; PWM output PA0
TIM2_CCR2       EQU TIM2_BASE + 0x38

TIM4_BASE       EQU 0x40000800
TIM4_CR1        EQU TIM4_BASE + 0x00
TIM4_CCMR2      EQU TIM4_BASE + 0x1C
TIM4_CCER       EQU TIM4_BASE + 0x20
TIM4_PSC        EQU TIM4_BASE + 0x28
TIM4_ARR        EQU TIM4_BASE + 0x2C
TIM4_CCR3       EQU TIM4_BASE + 0x3C      ; PWM output PB8
TIM4_CCR4       EQU TIM4_BASE + 0x40      ; PWM output PB9

TIM3_BASE       EQU 0x40000400
TIM3_CR1        EQU TIM3_BASE + 0x00
TIM3_CCMR1      EQU TIM3_BASE + 0x18
TIM3_CCER       EQU TIM3_BASE + 0x20
TIM3_PSC        EQU TIM3_BASE + 0x28
TIM3_ARR        EQU TIM3_BASE + 0x2C
TIM3_CCR1       EQU TIM3_BASE + 0x34      ; PWM output PA6

;########################## CONSTANTS ##########################;
PWM_MAX         EQU 1000
TRIG_PIN        EQU (1 << 6)              ; Trigger pin PB6
ECHO_PIN        EQU (1 << 7)              ; Echo pin PB7
LED_PIN         EQU (1 << 8)              ; LED pin PB8
DELAY_10US      EQU 720                   ; 10us delay for 72MHz
TIMEOUT_COUNT   EQU 0x00020000            ; Timeout threshold
ECHO_THRESHOLD  EQU 3000                  ; Echo distance threshold
DELAY_INTERVAL 	EQU 0x186004              ; ~1 second delay
DELAY_3SEC      EQU 0x200000              ; ~3 second delay

;########################## IMPORTED FUNCTIONS ##########################;
IMPORT MOVE_FORWARD
IMPORT MOVE_RIGHT
IMPORT MOVE_LEFT
IMPORT MOVE_BACKWARD
IMPORT STOP_CAR
IMPORT TURN_ON_PUMP
IMPORT TURN_OFF_PUMP
IMPORT DELAY_10SEC
IMPORT delay_1_second
IMPORT Bluetooth_ReceiveLoop
IMPORT GPIOA_INIT
IMPORT set_pwm
IMPORT SET_PWM
IMPORT Angry_face
IMPORT Smiley_face
IMPORT SETUP3

;########################## MAIN ENTRY ##########################;
AREA MA3LENA, CODE, READONLY
EXPORT __main

__main FUNCTION 

	BL GPIOA_INIT               ; Initialize GPIOA
	MOV R1, #850
	BL SET_PWM                 ; Set default PWM speed
	BL SETUP3                 ; Setup LCD or display
	BL Smiley_face            ; Display happy face

FLAME_LOOP1

	LDR r0, =GPIOB_IDR	
    LDR r1, [r0]
    ANDS r1, r1, #(1 << 4)    ; Check flame sensor on PB4
	BNE  SERVO_FELNOS         ; If flame detected, go to fire routine
	BL Smiley_face
	B	 main_loop            ; Else continue normal loop
	LTORG

;########################## FIRE RESPONSE ##########################;
SERVO_FELNOS
	BL  STOP_CAR              ; Stop motors
	BL  Angry_face           ; Display angry face

	; Repeated motion of servo spraying (oscillating pattern)
	MOV R1, #1
	BL set_pwm
	BL	DELAY_10SEC
	MOV R1, #490
	BL set_pwm
	BL DELAY_10SEC
	MOV R1, #1
	BL set_pwm
	BL DELAY_10SEC
	MOV R1, #490
	BL set_pwm
	BL DELAY_10SEC
	MOV R1, #1
	BL set_pwm
	BL DELAY_10SEC
	MOV R1, #490
	BL set_pwm
	BL DELAY_10SEC
	MOV R1, #1
	BL set_pwm
	BL DELAY_10SEC
	MOV R1, #490
	BL DELAY_10SEC
	B  FLAME_LOOP1

;########################## ULTRASONIC SENSOR LOGIC ##########################;
main_loop
        ; Send trigger pulse
        LDR     R0, =GPIOB_ODR
        LDR     R1, [R0]
        ORR     R1, R1, #TRIG_PIN
        STR     R1, [R0]

        MOV     R6, #DELAY_10US
pulse_delay
        SUBS    R6, R6, #1
        BNE     pulse_delay

        LDR     R1, [R0]
        BIC     R1, R1, #TRIG_PIN
        STR     R1, [R0]

        ; Wait for echo high
        MOV     R4, #0
        MOV     R5, #0
wait_echo_high
        LDR     R2, =GPIOB_IDR
        LDR     R3, [R2]
        ANDS    R3, R3, #ECHO_PIN
        BNE     echo_high

        ADDS    R4, R4, #1
        ADC     R5, R5, #0
        CMP     R5, #0
        BNE     check_timeout_high
        LDR     R6, =TIMEOUT_COUNT
        CMP     R4, R6
        BLO     wait_echo_high
        B       timeout

check_timeout_high
        LDR     R6, =TIMEOUT_COUNT
        CMP     R5, R6, LSR #16
        BHS     timeout
        B       wait_echo_high

echo_high
        MOV     R4, #0
        MOV     R5, #0
wait_echo_low
        LDR     R3, [R2]
        ANDS    R3, R3, #ECHO_PIN
        BEQ     echo_low

        ADDS    R4, R4, #1
        ADC     R5, R5, #0
        CMP     R5, #0
        BNE     check_timeout_low
        LDR     R6, =TIMEOUT_COUNT
        CMP     R4, R6
        BLO     wait_echo_low
        B       timeout

check_timeout_low
        LDR     R6, =TIMEOUT_COUNT
        CMP     R5, R6, LSR #16
        BHS     timeout
        B       wait_echo_low

echo_low
        MOV     R12, R4                 ; Store measured echo width in R12

        LDR     R0, =ECHO_THRESHOLD
        CMP     R4, R0
        BHI     LOOP                    ; No object nearby, go to line tracking

        ; Object detected within range
        BL	STOP_CAR
		BL  Bluetooth_ReceiveLoop      ; Wait for Bluetooth input
        B   FLAME_LOOP1

timeout
        ; Timeout handling — skip detection
        B   LOOP

;########################## LINE TRACKING LOGIC ##########################;
LOOP
	    LDR     R0, =GPIOA_IDR
        LDR     R1, [R0]
        MOV     R2, R1
        LSRS    R2, R2, #11
        ANDS    R2, R2, #0x13          ; Isolate PA2, PA3, PA4 (C, L, R)

        ; Center line detected
        CMP     R2, #0x01
        BEQ     MOVE_FORWARD_MAIN
		CMP     R2, #0x13
        BEQ     MOVE_FORWARD_MAIN

        ; Left line detected
        CMP     R2, #0x02
        BEQ     MOVE_LEFT_MAIN
		CMP     R2, #0x03
        BEQ     MOVE_LEFT_MAIN 
		CMP     R2, #0x12
        BEQ     MOVE_LEFT_MAIN 

        ; Right line detected
        CMP     R2, #0x10
        BEQ     MOVE_RIGHT_MAIN 
		CMP     R2, #0x11
        BEQ     MOVE_FORWARD_MAIN 

        ; No line — stop
        B		NO_LINE

MOVE_FORWARD_MAIN
	BL	MOVE_FORWARD
	B  FLAME_LOOP1

MOVE_LEFT_MAIN
	BL	MOVE_LEFT
	B  FLAME_LOOP1

MOVE_RIGHT_MAIN
	BL	MOVE_RIGHT
	B	FLAME_LOOP1

MOVE_BACKWARD_MAIN
	BL	MOVE_BACKWARD
	B	FLAME_LOOP1

NO_LINE
	BL	STOP_CAR
	B	FLAME_LOOP1

	BX LR
	ENDFUNC

	END
