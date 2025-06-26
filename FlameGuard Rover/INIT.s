	AREA    MYDAT, DATA, READONLY

;##########################ADDRESSES##############################;
RCC_BASE	EQU 	 0x40021000 
RCC_APB2ENR EQU		RCC_BASE + 0x018
RCC_APB1ENR     EQU     RCC_BASE + 0x1C
GPIOA_BASE 	EQU		  0x40010800 
GPIOA_MODERL EQU 	GPIOA_BASE + 0x0
GPIOA_MODERH EQU 	GPIOA_BASE + 0x04
GPIOA_ODR	EQU		GPIOA_BASE + 0x0C
GPIOA_IDR	EQU		GPIOA_BASE + 0x08
GPIOA_BSRR	EQU		GPIOA_BASE + 0x10
GPIOA_BRR   EQU		GPIOA_BASE + 0x14
GPIOB_BASE      EQU     0x40010C00
GPIOB_CRL       EQU     GPIOB_BASE + 0x00
GPIOB_CRH       EQU     GPIOB_BASE + 0x04
GPIOB_IDR       EQU     GPIOB_BASE + 0x08
GPIOB_ODR       EQU     GPIOB_BASE + 0x0C
GPIOB_BSRR	EQU		GPIOB_BASE + 0x10
GPIOB_BRR   EQU		GPIOB_BASE + 0x14
USART1_BASE    EQU  0x40013800
USART1_CR1     EQU  USART1_BASE + 0x0C	; Enable TX, RX, USART
USART1_BRR     EQU  USART1_BASE + 0x08	; Baud rate
USART1_SR      EQU  USART1_BASE + 0x00	; Status (TXE, RXNE)
USART1_DR      EQU  USART1_BASE + 0x04	; Data register
; === Pin Bitmasks ===
AFIO_BASE       EQU     0x40010000
AFIO_MAPR       EQU     AFIO_BASE + 0x04
TIM2_BASE       EQU     0x40000000
TIM2_CR1        EQU     TIM2_BASE + 0x00
TIM2_CCMR1      EQU     TIM2_BASE + 0x18
TIM2_CCER       EQU     TIM2_BASE + 0x20
TIM2_PSC        EQU     TIM2_BASE + 0x28
TIM2_ARR        EQU     TIM2_BASE + 0x2C
TIM2_CCR1       EQU     TIM2_BASE + 0x34    ; PA0
TIM2_CCR2       EQU     TIM2_BASE + 0x38
PWM_MAX         EQU     1000
TRIG_PIN        EQU     (1 << 6)    ; PB6
ECHO_PIN        EQU     (1 << 7)    ; PB7
LED_PIN         EQU     (1 << 8)    ; PB8
TIM3_BASE       EQU     0x40000400
TIM3_CR1        EQU     TIM3_BASE + 0x00
TIM3_CCMR1      EQU     TIM3_BASE + 0x18
TIM3_CCER       EQU     TIM3_BASE + 0x20
TIM3_PSC        EQU     TIM3_BASE + 0x28
TIM3_ARR        EQU     TIM3_BASE + 0x2C
TIM3_CCR1       EQU     TIM3_BASE + 0x34    ; PA6 output
TIM4_BASE       EQU     0x40000800
TIM4_CR1        EQU     TIM4_BASE + 0x00
TIM4_CCMR2      EQU     TIM4_BASE + 0x1C
TIM4_CCER       EQU     TIM4_BASE + 0x20
TIM4_PSC        EQU     TIM4_BASE + 0x28
TIM4_ARR        EQU     TIM4_BASE + 0x2C
TIM4_CCR3       EQU     TIM4_BASE + 0x3C    ; PB8 (TIM2_CH3)
TIM4_CCR4       EQU     TIM4_BASE + 0x40    ; PB9 (TIM2_CH4)
	
	
    AREA MyCode, CODE, READONLY

;##########################EXPORT##############################;
	EXPORT GPIOA_INIT

;##########################FUNCTIONS##############################;
GPIOA_INIT
	
	push {R0-R12,LR}
	
	LDR R0, =RCC_APB2ENR
	LDR R1, [R0]
	MOV R2, #1
	ORR R1, R1, R2,LSL #2
	STR R1, [R0]
	
	LDR R0, =GPIOA_MODERL
	LDR     R1, [R0]
	BIC     R1, R1, #(0xF << 0)   ; Clear PA0 config
	BIC     R1, R1, #(0xF << 4)   ; Clear PA1 config
	BIC     R1, R1, #(0xF << 8)   ; Clear PA2 config
	BIC     R1, R1, #(0xF << 12)  ; Clear PA3 config
	ORR     R1, R1, #(0x3 << 0)   ; PA0: Output 50 MHz (0b0011)
	ORR     R1, R1, #(0x3 << 4)   ; PA1: Output 50 MHz (0b0011)
	ORR     R1, R1, #(0x3 << 8)   ; PA2: Output 50 MHz (0b0011)
	ORR     R1, R1, #(0x3 << 12)  ; PA3: Output 50 MHz (0b0011)
	STR     R1, [R0]

	
	LDR R0, =GPIOA_MODERH
	LDR     R1, [R0]
	BIC     R1, R1, #(0xF << 12)   ; Clear PA11 config
	BIC     R1, R1, #(0xF << 16)   ; Clear PA12 config
	BIC     R1, R1, #(0xF << 28)   ; Clear PA15 config
	ORR     R1, R1, #(0x4 << 12)   ; PA11: INPUT
	ORR     R1, R1, #(0x4 << 16)   ; PA12: INPUT
	ORR     R1, R1, #(0x4 << 28)   ; PA15: INPUT
	STR     R1, [R0]
	
	; Enable clocks for GPIOA and USART1
	LDR     R0, =RCC_APB2ENR
	LDR     R1, [R0]
	MOV		R3, #0X4000
	ORR     R1, R1, R3     ; IOPAEN and USART1EN
	STR     R1, [R0]

	; Configure PA9 (TX) and PA10 (RX)
	LDR     R0, =GPIOA_MODERH
	LDR     R1, [R0]
	
	; Clear PA9 and PA10 config bits (4 bits each)
	BIC     R1, R1, #(0xF << 4)  ; Clear PA9 config
	BIC     R1, R1, #(0xF << 8)  ; Clear PA10 config
	
	; Set PA9 as AF Push-Pull, 50MHz: MODE = 0b11, CNF = 0b10 ? 0b1011 = 0xB
	ORR     R1, R1, #(0xB << 4)  ; PA9: AF Push-Pull

	; Set PA10 as input floating: MODE = 0b00, CNF = 0b01 ? 0b0100 = 0x4
	ORR     R1, R1, #(0x4 << 8)  ; PA10: Input Floating
	
	; Write configuration back to GPIOA_CRH
	STR     R1, [R0]

	; Set baud rate (9600 @ 72MHz ? 0x1D4C)
	LDR     R0, =USART1_BRR
	LDR     R1, =0x1D4C
	STR     R1, [R0]

	; Enable USART1 (UE | TE | RE)
	LDR     R0, =USART1_CR1
	MOV     R1, #0x200C           ; UE=1, TE=1, RE=1
	STR     R1, [R0]
	
				
	LDR     R0, =RCC_APB2ENR
    LDR     R1, [R0]
    ORR     R1, R1, #(1 << 3)
    STR     R1, [R0]

; Configure PB6 (Output), PB7 (Input), PB8 (Output)
    LDR     R0, =GPIOB_CRL
    LDR     R1, [R0]
        ; Clear bits for PB6 and PB7
	
	BIC     R1, R1, #(0xF << 12)     ; PB3
	BIC     R1, R1, #(0xF << 16)     ; PB4
	BIC     R1, R1, #(0xF << 20)     ; PB5
    BIC     R1, R1, #(0xF << 24)     ; PB6
    BIC     R1, R1, #(0xF << 28)     ; PB7
	
	ORR     R1, R1, #(0x4 << 12)     ; PB3 = Input floating, flame1
    ORR     R1, R1, #(0x2 << 24)     ; PB6 = Output push-pull, 
	ORR     R1, R1, #(0x4 << 16)     ; PB4 = Input floating, flame2
	ORR     R1, R1, #(0x4 << 20)     ; PB5 = Input floating, flame3
    ORR     R1, R1, #(0x4 << 28)     ; PB7 = Input floating
    STR     R1, [R0]

        ; Configure PB8 as output (in CRH)
    LDR     R0, =GPIOB_CRH
    LDR     R1, [R0]
    BIC     R1, R1, #(0xFF << 0)      ; PB8,PB9
    ORR     R1, R1, #(0x32 << 0)      ; PB8 = Output push-pull,PB9 FOR PUMP
    STR     R1, [R0]
	LDR     R6, =72000
	
	LDR     R0, =GPIOB_CRH
    LDR     R1, [R0]
    BIC     R1, R1, #(0xF << 4)      ; PB12
    ORR     R1, R1, #(0x4 << 4)      ; PB12 = INPUT FLAME3
    STR     R1, [R0]
	LDR     R6, =72000
	; Enable GPIOA and AFIO clocks
        LDR     R0, =RCC_APB2ENR
        LDR     R1, [R0]
        ORR     R1, #(1<<0)          ; AFIOEN
        ORR     R1, #(1<<2)          ; GPIOAEN
        STR     R1, [R0]
	
; Enable TIM2 clock
        LDR     R0, =RCC_APB1ENR
        LDR     R1, [R0]
        ORR     R1, #(1<<0)          ; TIM2EN
        STR     R1, [R0]

; No remap TIM2
        LDR     R0, =AFIO_MAPR
        LDR     R1, [R0]
        BIC     R1, #(3<<8)          ; TIM2_REMAP = 00
        STR     R1, [R0]



; Timer config
        LDR     R0, =TIM2_PSC
        MOV     R1, #71
        STR     R1, [R0]

        LDR     R0, =TIM2_ARR
        MOV     R1, #PWM_MAX
        STR     R1, [R0]

        LDR     R0, =TIM2_CCMR1
        MOV     R1, #0x6860
        STR     R1, [R0]

        LDR     R0, =TIM2_CCER
        MOV     R1, #0x11
        STR     R1, [R0]

        LDR     R0, =TIM2_CR1
        MOV     R1, #0x81
        STR     R1, [R0]
		
		LDR     R0, =RCC_APB1ENR
        LDR     R1, [R0]
        ORR     R1, #(1<<1)          ; TIM3EN
        STR     R1, [R0]

; Configure PA6 as AF output push-pull (MODE=11, CNF=10 -> 0xB)
        LDR     R0, =GPIOA_MODERL
        LDR     R1, [R0]
        BIC     R1, #(0xF << (6*4))      ; Clear PA6
        ORR     R1, #(0xB << (6*4))      ; Set PA6 to AF Output Push-Pull
        STR     R1, [R0]

; Configure TIM3 for PWM
        LDR     R0, =TIM3_PSC
        MOV     R1, #71
        STR     R1, [R0]

        LDR     R0, =TIM3_ARR
        MOV     R1, #PWM_MAX
        STR     R1, [R0]

        LDR     R0, =TIM3_CCMR1
        MOV     R1, #0x0060             ; PWM Mode 1, OC1M = 110, OC1PE = 1
        STR     R1, [R0]

        LDR     R0, =TIM3_CCER
        MOV     R1, #0x01               ; Enable output on CH1
        STR     R1, [R0]

        LDR     R0, =TIM3_CR1
        MOV     R1, #0x81               ; Enable TIM3 (CEN), ARPE
        STR     R1, [R0]
		
		 ; 1. Enable Clocks
		; Enable GPIOB and AFIO clocks
		LDR     R0, =RCC_APB2ENR
		LDR     R1, [R0]
		ORR     R1, #(1<<0)          ; AFIOEN (bit 0)
		ORR     R1, #(1<<3)          ; GPIOBEN (bit 2)
		STR     R1, [R0]

		; Enable TIM4 clock
		LDR     R0, =RCC_APB1ENR
		LDR     R1, [R0]
		ORR     R1, #(1<<2)          ; TIM4EN (bit 0)  ;;;;;;
		STR     R1, [R0]

		; 2. Configure TIM2 Remapping - CRITICAL FIX
		; No remap needed for PA0 (CH1) and PA1 (CH2) - they are default
		; But let's explicitly clear any remapping
		LDR     R0, =AFIO_MAPR
		LDR     R1, [R0]
		BIC     R1, #(1<<12)          ; Clear TIM4_REMAP[1:0] bits
		STR     R1, [R0]

		; 3. Configure GPIO Pins
		; PB8: TIM4_CH3 (no remap)
		; PB9: TIM4_CH4 (no remap)
		LDR     R0, =GPIOB_CRH
		LDR     R1, [R0]
		; Configure PB8 (bits 0-3): CNF=10, MODE=11 (AF PP, 50MHz)
		BIC     R1, #0xF             ; Clear PB8 config
		ORR     R1, #0xB             ; AF PP, 50MHz (0b1011)
		; Configure PB9 (bits 4-7): CNF=10, MODE=11 (AF PP, 50MHz)
		BIC     R1, #(0xF<<4)        ; Clear PB9 config
		ORR     R1, #(0xB<<4)        ; AF PP, 50MHz (0b1011)
		STR     R1, [R0]

		; 4. Configure TIM4
		; Prescaler for 1MHz counter (72MHz/72)
		LDR     R0, =TIM4_PSC
		MOV     R1, #71
		STR     R1, [R0]

		; Auto-reload for 1kHz PWM (1000 cycles)
		LDR     R0, =TIM4_ARR
		MOV     R1, #PWM_MAX
		STR     R1, [R0]

		; PWM Mode Configuration
		LDR     R0, =TIM4_CCMR2
		; OC3M = 110 (PWM mode 1), OC3PE = 1 (bits 6:4 = 110, bit 3 = 1)
		; OC4M = 110 (PWM mode 1), OC4PE = 1 (bits 14:12 = 110, bit 11 = 1)
		MOV     R1, #0x6860          ; Correct value for both channels
		STR     R1, [R0]

		; Enable Capture/Compare
		LDR     R0, =TIM4_CCER
		MOV     R1, #0x1100            ; CC3E (bit 8) + CC4E (bit 12)
		STR     R1, [R0]

		; Enable TIM2 with Auto-reload Preload
		LDR     R0, =TIM4_CR1
		MOV     R1, #0x81            ; CEN=1, ARPE=1
		STR     R1, [R0]
		
startup_delay
    SUBS    R6, R6, #1
    BNE     startup_delay	
	
		pop {R0-R12,PC}
		BX LR