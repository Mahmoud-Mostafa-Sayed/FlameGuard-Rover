	AREA    MYDAT, DATA, READONLY

;##########################ADDRESSES##############################;
TIM4_BASE       EQU     0x40000800             ; Base address for Timer 4
TIM4_CR1        EQU     TIM4_BASE + 0x00       ; Timer 4 control register 1
TIM4_CCMR2      EQU     TIM4_BASE + 0x1C       ; Timer 4 capture/compare mode register 2
TIM4_CCER       EQU     TIM4_BASE + 0x20       ; Timer 4 capture/compare enable register
TIM4_PSC        EQU     TIM4_BASE + 0x28       ; Timer 4 prescaler
TIM4_ARR        EQU     TIM4_BASE + 0x2C       ; Timer 4 auto-reload register (sets PWM period)
TIM4_CCR3       EQU     TIM4_BASE + 0x3C       ; Capture/compare register 3 (PB8 - TIM4_CH3)
TIM4_CCR4       EQU     TIM4_BASE + 0x40       ; Capture/compare register 4 (PB9 - TIM4_CH4)

TIM3_BASE       EQU     0x40000400             ; Base address for Timer 3
TIM3_CR1        EQU     TIM3_BASE + 0x00       ; Timer 3 control register 1
TIM3_CCMR1      EQU     TIM3_BASE + 0x18       ; Timer 3 capture/compare mode register 1
TIM3_CCER       EQU     TIM3_BASE + 0x20       ; Timer 3 capture/compare enable register
TIM3_PSC        EQU     TIM3_BASE + 0x28       ; Timer 3 prescaler
TIM3_ARR        EQU     TIM3_BASE + 0x2C       ; Timer 3 auto-reload register
TIM3_CCR1       EQU     TIM3_BASE + 0x34       ; Capture/compare register 1 (PA6 - TIM3_CH1)

    AREA MyCode, CODE, READONLY

;##########################EXPORT##############################;
	EXPORT set_pwm                        ; Export function to set PWM on TIM3_CH1
	EXPORT SET_PWM                        ; Export function to set PWM on TIM4_CH3 and CH4

;##########################FUNCTIONS##############################;

set_pwm FUNCTION
        ; Sets PWM duty cycle on TIM3_CH1 (PA6)
        ; Input: R1 = PWM duty value (0-1000 or other resolution)
        LDR     R0, =TIM3_CCR1            ; Load address of TIM3 CCR1
        STR     R1, [R0]                  ; Store duty cycle value into CCR1
        BX      LR                        ; Return from function
        ENDFUNC

SET_PWM FUNCTION
        ; Sets PWM duty cycle on both TIM4_CH3 (PB8) and TIM4_CH4 (PB9)
        ; Input: R1 = PWM duty value (0-1000 or other resolution)
        LDR     R0, =TIM4_CCR3            ; Load address of TIM4 CCR3 (PB8)
        STR     R1, [R0]                  ; Store duty cycle value into CCR3
        LDR     R0, =TIM4_CCR4            ; Load address of TIM4 CCR4 (PB9)
        STR     R1, [R0]                  ; Store duty cycle value into CCR4
        BX      LR                        ; Return from function
        ENDFUNC