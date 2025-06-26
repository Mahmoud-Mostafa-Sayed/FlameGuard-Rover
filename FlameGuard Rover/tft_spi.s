	INCLUDE ADC.s
	AREA MyData, DATA, READONLY
		


HORIZONTAL		EQU		0
VERTICAL		EQU		1

LINE_THICKNESS	EQU		2
LINE_LENGTH		EQU		8


; in port B
RST_PIN EQU 1
DC_PIN EQU 0




;just some color codes, 16-bit colors coded in RGB 565
BLACK		EQU   	(~0x000000)
RED  		EQU  	(~0xFF0000)
GREEN		EQU		(~0x00FF00)
BLUE 		EQU  	(~0x0000FF)
WHITE		EQU		(~0xFFFFFF)

CYAN  		EQU  	(~0x003818)
ORANGE		EQU   	(~0x3F1800)
PURPLE		EQU   	(~0x3C001F)
BROWN		EQU   	(~0x0E8800)
WOODEN		EQU   	(~0x060E00)
YELLOW		EQU   	(~0x7F3800)
LEAFY		EQU   	(~0x0C1E00)
AQUA		EQU   	(~0x007F3C)
VIOLET		EQU		(~0x3F1800)



	AREA MyCode, CODE, READONLY
	
;##############################################################################################################################
	EXPORT SETUP3



;#####################################################################################################################################################################
LCD_COMMAND_WRITE
	;this function writes a command to the TFT, the command is read from R2
	;it writes LOW to RS first to specify that we are writing a command not data.
	;then it normally calls the function LCD_WRITE we just defined above
	;arguments: R2 = data to be written on D0-7 bus

	;TODO: PUSH ANY NEEDED REGISTERS
	PUSH {R0-R1,LR}
	

	;;;;;;;;;;;;;;;;;;;;;;;;;; SETTING RD to 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;TODO: SET RD HIGH (we won't need reading anyways, but we must keep read pin to high, which means we will not read anything) (deleted)

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



	;;;;;;;;;;;;;;;;;;;;;;;;; SETTING RS to 0 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;TODO: SET RS TO 0 (to specify that we are writing commands not data on the D0-7 bus)
	LDR r1,=GPIOB_ODR
	LDR r0,[r1]
	BIC r0,r0,#(1<<DC_PIN)
	STR r0,[r1]
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;TODO: CALL FUNCTION LCD_WRITE
	;BL LCD_WRITE
	BL SPI_SEND

	;TODO: POP ALL REGISTERS YOU PUSHED
	POP {R0-R1,PC}
	
;#####################################################################################################################################################################






;#####################################################################################################################################################################
LCD_DATA_WRITE
	;this function writes Data to the TFT, the data is read from R2
	;it writes HIGH to RS first to specify that we are writing actual data not a command.
	;arguments: R2 = data

	;TODO: PUSH ANY NEEDED REGISTERS
	PUSH {R0-R1,LR}


	;;;;;;;;;;;;;;;;;;;;;;;;;; SETTING RD to 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;TODO: SET RD HIGH (we won't need reading anyways, but we must keep read pin to high, which means we will not read anything) (deleted)

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	



	;;;;;;;;;;;;;;;;;;;; SETTING RS to 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;TODO: SET RS TO 1 (to specify that we are sending actual data not a command on the D0-7 bus)
	LDR r1,=GPIOB_ODR
	LDR r0,[r1]
	ORR r0,r0,#(1<<DC_PIN)
	STR r0,[r1]
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



	;TODO: CALL FUNCTION LCD_WRITE
	BL SPI_SEND

	;TODO: POP ANY REGISTER YOU PUSHED
	POP{R0-R1,PC}
;#####################################################################################################################################################################




; REVISE WITH YOUR TA THE LAST 3 FUNCTIONS (LCD_WRITE, LCD_COMMAND_WRITE AND LCD_DATA_WRITE BEFORE PROCEEDING)




;#####################################################################################################################################################################
LCD_INIT
	;This function executes the minimum needed LCD initialization measures
	;Only the necessary Commands are covered
	;Eventho there are so many more in the DataSheet

	;TODO: PUSH ANY NEEDED REGISTERS
	PUSH {R0-R2,LR}
	
	

	;;;;;;;;;;;;;;;;; HARDWARE RESET (putting RST to high then low then high again) ;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;TODO: SET RESET PIN TO HIGH
	LDR r1,=GPIOB_ODR
	LDR r0,[r1]
	ORR r0,r0,#(1<<RST_PIN)
	STR r0,[r1]

	;TODO: DELAY FOR SOME TIME (USE ANY FUNCTION AT THE BOTTOM OF THIS FILE)
	BL delay_1_second

	;TODO: RESET RESET PIN TO LOW
	LDR r1,=GPIOB_ODR
	LDR r0,[r1]
	BIC r0,r0,#(1<<RST_PIN)
	STR r0,[r1]

	;TODO: DELAY FOR SOME TIME (USE ANY FUNCTION AT THE BOTTOM OF THIS FILE)
	BL delay_1_second

	;TODO: SET RESET PIN TO HIGH AGAIN
	LDR r1,=GPIOB_ODR
	LDR r0,[r1]
	ORR	r0,r0,#(1<<RST_PIN)
	STR r0,[r1]

	;TODO: DELAY FOR SOME TIME (USE ANY FUNCTION AT THE BOTTOM OF THIS FILE)
	BL delay_1_second
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	LDR R0, =GPIOA_ODR
	MOV R3, #CS_PIN
	BL setBit


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	LDR R0, =GPIOA_ODR
	MOV R3, #CS_PIN
	BL clearBit

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SOFTWARE INITIALIZATION SEQUENCE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	MOV R2, #0x01
	BL LCD_COMMAND_WRITE		; software reset
	
	;SLEEP OUT | DATASHEET PAGE 101
	;TODO: ISSUE THE SLEEP OUT COMMAND TO EXIT SLEEP MODE (THIS COMMAND TAKES NO PARAMETERS, JUST SEND THE COMMAND)
	MOV r2,#0x11
	BL LCD_COMMAND_WRITE
		
	BL delay_half_second
	
	;ISSUE THE "SET CONTRAST" COMMAND, ITS HEX CODE IS 0xC5
	MOV R2, #0xC0
	BL LCD_COMMAND_WRITE


	;THIS COMMAND REQUIRES 2 PARAMETERS TO BE SENT AS DATA, THE VCOM H, AND THE VCOM L
	;WE WANT TO SET VCOM H TO A SPECIFIC VOLTAGE WITH CORRESPONDS TO A BINARY CODE OF 1111111 OR 0x7F HEXA
	;SEND THE FIRST PARAMETER (THE VCOM H) NEEDED BY THE COMMAND, WITH HEX 0x7F, PARAMETERS ARE SENT AS DATA BUT COMMANDS ARE SENT AS COMMANDS
	MOV R2, #0x7F
	BL LCD_DATA_WRITE
	
		;COLMOD: PIXEL FORMAT SET | DATASHEET PAGE 134
	;THIS COMMAND LETS US CHOOSE WHETHER WE WANT TO USE 16-BIT COLORS OR 18-BIT COLORS.
	;WE WILL ALWAYS USE 16-BIT COLORS
	;TODO: ISSUE THE COMMAND COLMOD
	MOV R2, #0x3A
	BL LCD_COMMAND_WRITE

	;TODO: SEND THE NEEDED PARAMETER WHICH CORRESPONDS TO 16-BIT RGB AND 16-BIT MCU INTERFACE FORMAT
	MOV R2,#0x55
	BL LCD_DATA_WRITE
	
	;MEMORY ACCESS CONTROL AKA MADCLT | DATASHEET PAGE 127
	;WE WANT TO SET MX (to draw from left to right) AND SET MV (to configure the TFT to be in horizontal landscape mode, not a vertical screen)
	;TODO: ISSUE THE COMMAND MEMORY ACCESS CONTROL, HEXCODE 0x36
	MOV R2, #0x36
	BL LCD_COMMAND_WRITE
	
	MOV R2, #0x08
	BL LCD_DATA_WRITE		; rotation and RGB order

	;WE WANT TO SET VCOM L TO A SPECIFIC VOLTAGE WITH CORRESPONDS TO A BINARY CODE OF 00000000 OR 0x00 HEXA
	;SEND THE SECOND PARAMETER (THE VCOM L) NEEDED BY THE CONTRAST COMMAND, WITH HEX 0x00, PARAMETERS ARE SENT AS DATA BUT COMMANDS ARE SENT AS COMMANDS
	;MOV R2, #0x60
	;BL LCD_DATA_WRITE

	
	;NECESSARY TO WAIT 5ms BEFORE SENDING NEXT COMMAND
	;I WILL WAIT FOR 10MSEC TO BE SURE
	;TODO: DELAY FOR AT LEAST 10ms
	;BL delay_10_milli_second


	;COLOR INVERSION OFF | DATASHEET PAGE 105
	;NOTE: SOME TFTs HAS COLOR INVERTED BY DEFAULT, SO YOU WOULD HAVE TO INVERT THE COLOR MANUALLY SO COLORS APPEAR NATURAL
	;MEANING THAT IF THE COLORS ARE INVERTED WHILE YOU ALREADY TURNED OFF INVERSION, YOU HAVE TO TURN ON INVERSION NOT TURN IT OFF.
	;TODO: ISSUE THE COMMAND, IT TAKES NO PARAMETERS
	MOV R2,#0x21
	BL LCD_COMMAND_WRITE	


	;DISPLAY ON | DATASHEET PAGE 109
	;TODO: ISSUE THE COMMAND, IT TAKES NO PARAMETERS
	MOV r2, #0x29
	BL LCD_COMMAND_WRITE
	
	BL delay_half_second

	;MEMORY WRITE | DATASHEET PAGE 114
	;WE NEED TO PREPARE OUR TFT TO SEND PIXEL DATA, MEMORY WRITE SHOULD ALWAYS BE ISSUED BEFORE ANY PIXEL DATA SENT
	;TODO: ISSUE MEMORY WRITE COMMAND
	MOV R2,#0x2C
	BL LCD_COMMAND_WRITE

	LDR R0, =GPIOA_ODR
	MOV R3, #CS_PIN
	BL setBit

	;TODO: POP ALL PUSHED REGISTERS
	POP {R0-R2,PC}

;#####################################################################################################################################################################


;#####################################################################################################################################################################
SETUP3
	;THIS FUNCTION ENABLES PORT E, MARKS IT AS OUTPUT, CONFIGURES SOME GPIO
	;THEN FINALLY IT CALLS LCD_INIT (HINT, USE THIS SETUP FUNCTION DIRECTLY IN THE MAIN)
	PUSH {R0-R12, LR}
	
	LDR R0, =RCC_APB2ENR
	MOV R3, #2
	BL setBit

	LDR R0, =RCC_APB2ENR
	MOV R3, #3
	BL setBit
	
			;;;;;;;; TFT pins configurations ;;;;;;;
	
	LDR R0, =GPIOB_CRL
	LDR R1, [R0]
	MOV R2, #0xF				; specifying four bits to clear
	MOV R3, #(4*RST_PIN)
	BL clearMultiBits
	MOV R2, #0x3				; specifying the bits to set
	MOV R3, #(4*RST_PIN)
	BL setMultiBits
	
	
	LDR R0, =GPIOB_CRL
	LDR R1, [R0]
	MOV R2, #0xF				; specifying four bits to clear
	MOV R3, #(4*DC_PIN)
	BL clearMultiBits
	MOV R2, #0x3				; specifying the bits to set
	MOV R3, #(4*DC_PIN)
	BL setMultiBits


	LDR R0, =GPIOB_ODR
	MOV R3, #DC_PIN
	BL setBit
	
	LDR R0, =GPIOB_ODR
	MOV R3, #RST_PIN
	BL setBit
	
	LDR R0, =GPIOA_ODR
	MOV R3, #CS_PIN
	BL setBit
	
	BL SPI_INIT
	
	BL delay_1_second
	BL delay_1_second
	
	BL LCD_INIT

	POP {R0-R12, PC}
;#####################################################################################################################################################################





; REVISE THE FUNCTION LCD_INIT WITH YOUR TA BEFORE PROCEEDING







;#####################################################################################################################################################################
ADDRESS_SET
	;THIS FUNCTION TAKES X1, X2, Y1, Y2
	;IT ISSUES COLUMN ADDRESS SET TO SPECIFY THE START AND END COLUMNS (X1 AND X2)
	;IT ISSUES PAGE ADDRESS SET TO SPECIFY THE START AND END PAGE (Y1 AND Y2)
	;THIS FUNCTION JUST MARKS THE PLAYGROUND WHERE WE WILL ACTUALLY DRAW OUR PIXELS, MAYBE TARGETTING EACH PIXEL AS IT IS.
	PUSH {R0-R7,LR}
	;R4 = Y1
	;R5 = Y2
	;R6 = X1
	;R7 = X2
	 
	LDR R0, =GPIOA_ODR
	MOV R3, #CS_PIN
	BL clearBit
	 
	;PUSHING ANY NEEDED REGISTERS

	;COLUMN ADDRESS SET | DATASHEET PAGE 110
	MOV R2, #0x2A
	BL LCD_COMMAND_WRITE
	
	;TODO: SEND THE FIRST PARAMETER (HIGHER 8-BITS OF THE STARTING COLUMN, AKA HIGHER 8-BITS OF X1)
	LSR R2, R4, #8
	BL LCD_DATA_WRITE
	
	;TODO: SEND THE SECOND PARAMETER (LOWER 8-BITS OF THE STARTING COLUMN, AKA LOWER 8-BITS OF X1)
	AND R2, R4, #0x00FF
	BL LCD_DATA_WRITE

	;TODO: SEND THE THIRD PARAMETER (HIGHER 8-BITS OF THE ENDING COLUMN, AKA HIGHER 8-BITS OF X2)
	LSR R2, R5, #8
	BL LCD_DATA_WRITE

	;TODO: SEND THE FOURTH PARAMETER (LOWER 8-BITS OF THE ENDING COLUMN, AKA LOWER 8-BITS OF X2)
	AND R2, R5, #0x00FF
	BL LCD_DATA_WRITE

	;PAGE ADDRESS SET | DATASHEET PAGE 110
	MOV R2, #0x2B
	BL LCD_COMMAND_WRITE

	;TODO: SEND THE FIRST PARAMETER (HIGHER 8-BITS OF THE STARTING PAGE, AKA HIGHER 8-BITS OF Y1)
	LSR R2, R6, #8
	BL LCD_DATA_WRITE

	;TODO: SEND THE SECOND PARAMETER (LOWER 8-BITS OF THE STARTING PAGE, AKA LOWER 8-BITS OF Y1)
	AND R2, R6, #0x00FF
	BL LCD_DATA_WRITE

	;TODO: SEND THE THIRD PARAMETER (HIGHER 8-BITS OF THE ENDING PAGE, AKA HIGHER 8-BITS OF Y2)
	LSR R2, R7, #8
	BL LCD_DATA_WRITE
	
	;TODO: SEND THE FOURTH PARAMETER (LOWER 8-BITS OF THE ENDING PAGE, AKA LOWER 8-BITS OF Y2)
	AND R2, R7, #0x00FF
	BL LCD_DATA_WRITE
	
	;MEMORY WRITE
	MOV R2, #0x2C
	BL LCD_COMMAND_WRITE
	
	LDR R0, =GPIOA_ODR
	MOV R3, #CS_PIN
	BL setBit

	;POPPING ALL REGISTERS I PUSHED
	POP {R0-R7,PC}
;#####################################################################################################################################################################



;#####################################################################################################################################################################
DRAW_PIXEL

	
	;THIS FUNCTION TAKES X AND Y AND A COLOR AND DRAWS THIS EXACT PIXEL
	;NOTE YOU HAVE TO CALL ADDRESS SET ON A SPECIFIC PIXEL WITH LENGTH 1 AND WIDTH 1 FROM THE STARTING COORDINATES OF THE PIXEL, THOSE STARTING COORDINATES ARE GIVEN AS PARAMETERS
	;THEN YOU SIMPLY ISSUE MEMORY WRITE COMMAND AND SEND THE COLOR
	;R4 = X
	;R5 = Y
	;R10 = COLOR
	PUSH {R0-R12,LR}
	
	;CHIP SELECT ACTIVE, WRITE LOW TO CS
	
	LDR R0, =GPIOA_ODR
	MOV R3, #CS_PIN
	BL clearBit
	
	
	;TODO: SETTING PARAMETERS FOR FUNC 'ADDRESS_SET' CALL, THEN CALL FUNCTION ADDRESS SET
	;NOTE YOU MIGHT WANT TO PERFORM PARAMETER REORDERING, AS ADDRESS SET FUNCTION TAKES X1, X2, Y1, Y2 IN R0, R1, R3, R4 BUT THIS FUNCTION TAKES X,Y IN R0 AND R1

	
	MOV R6, R5
	ADD R5, R4, #1
	ADD R7, R6, #1
	
	BL DRAW_RECTANGLE_FILLED
	
	
	LDR R0, =GPIOA_ODR
	MOV R3, #CS_PIN
	BL setBit

	;SEND THE COLOR DATA | DATASHEET PAGE 114
	;HINT: WE SEND THE HIGHER 8-BITS OF THE COLOR FIRST, THEN THE LOWER 8-BITS
	;HINT: WE SEND THE COLOR OF ONLY 1 PIXEL BY 2 DATA WRITES, THE FIRST TO SEND THE HIGHER 8-BITS OF THE COLOR, THE SECOND TO SEND THE LOWER 8-BITS OF THE COLOR
	;REMINDER: WE USE 16-BIT PER PIXEL COLOR
	;TODO: SEND THE SINGLE COLOR, PASSED IN R10
	
	; pop
	POP {R0-R4,R10,PC}
;#####################################################################################################################################################################


;	REVISE THE PREVIOUS TWO FUNCTIONS (ADDRESS_SET AND DRAW_PIXEL) WITH YOUR TA BEFORE PROCEEDING








;##########################################################################################################################################
DRAW_RECTANGLE_FILLED
	;TODO: IMPLEMENT THIS FUNCTION ENTIRELY, AND SPECIFY THE ARGUMENTS IN COMMENTS, WE DRAW A RECTANGLE BY SPECIFYING ITS TOP-LEFT AND LOWER-RIGHT POINTS, THEN FILL IT WITH THE SAME COLOR
	;R4 = Y1
	;R5 = Y2
	;R6 = X1
	;R7 = X2
	;R10 = color
	PUSH {R0-R12,LR}
	

	BL ADDRESS_SET
	
	SUB R5,R5,R4
	SUB R7,R7,R6
	MUL R5,R5,R7
	;ADD R5, #100
	
	LDR R0, =GPIOA_ODR
	MOV R3, #CS_PIN
	BL clearBit
	
	MOV R2, #0x2C
	BL LCD_COMMAND_WRITE
	
	
	
RECTANGLE
	LSR R2, R10, #11
	AND R2, #~0xF8
	LSR R3, R10, #13
	AND R3, #0xF8
	ORR R2, R3
	BL LCD_DATA_WRITE
	

	AND R2, R10, #~0xE0
	LSR R3, R10, #3
	AND R3, #0xE0
	ORR R2, R3
	BL LCD_DATA_WRITE
	
	SUB R5,#1
	CMP R5, #0
	BNE RECTANGLE
	
	LDR R0, =GPIOA_ODR
	MOV R3, #CS_PIN
	BL setBit
	
	POP{R0-R12,PC}
;##########################################################################################################################################

DRAW_TRIANGLE_FILLED
	;TODO: IMPLEMENT THIS FUNCTION ENTIRELY, AND SPECIFY THE ARGUMENTS IN COMMENTS, WE DRAW A RECTANGLE BY SPECIFYING ITS TOP-LEFT AND LOWER-RIGHT POINTS, THEN FILL IT WITH THE SAME COLOR
	;R4 = Y1
	;R5 = Y2
	;R6 = X1
	;R7 = X2
	;R10 = color
	PUSH {R0-R12,LR}
	

	BL ESCAPE
	LTORG
ESCAPE
	


DRAW_STRAIGHT_LINE

	PUSH {R0-R12,LR}
	
	;R0= orientation (0: horizontal, 1: vertical)
	;R1= center Y
	;R2= center X
	;R3= size
	;R10= color
	
	CMP R0, #VERTICAL
	BEQ Vertical
	BNE Horizontal
	
Horizontal
	MOV R8, #(LINE_THICKNESS/2)
	MUL R0, R3, R8
	SUB R4, R1, R0
	ADD R5, R1, R0
	MOV R8, #(LINE_LENGTH/2)
	MUL R0, R3, R8
	SUB R6, R2, R0
	ADD R7, R2, R0
	
	B BeginDraw

Vertical
	MOV R8, #(LINE_LENGTH/2)
	MUL R0, R3, R8
	SUB R4, R1, R0
	ADD R5, R1, R0
	MOV R8, #(LINE_THICKNESS/2)
	MUL R0, R3, R8
	SUB R6, R2, R0
	ADD R7, R2, R0
	
BeginDraw
	
	BL DRAW_RECTANGLE_FILLED
	
	POP{R0-R12,PC}
	
	
DRAW_SLOPED_LINE
	PUSH {R0-R12, LR}
	
	;R1= start Y
	;R2= start X
	;R4= end Y
	;R5= end X
	;R3= size
	;R10= color
	
	SUB R6, R4, R1
	SUB R7, R5, R2
	
	LDR R11, =(LINE_THICKNESS/2)
	MUL R11, R3
	;LDR R8, =2
	;MUL R8, R8
	;LDR R9, =3
	;BL Divide

	
	MOV R8, R6
	MOV R9, R11
	BL Divide
	MOV R8, R9
	
	;MOV R8, R7
	;MOV R9, R11
	;BL Divide
	;MOV R7, R9
	
	MOV R4, R1
	MOV R6, R2
slopeLineLoop
	
	ADD R5, R11
	;DRAW
	;ADD 
	
	
	SUB R6, #1
	CMP R6, #0
	BNE slopeLineLoop
	
	
	
	POP{R0-R12, PC}
	
;	 _
;	|_|
;	|_|



DRAW_MIDDLE
	PUSH {R0-R12, LR}			; Push all GPRs and Link Register (LR) onto the stack
	
	LDR R0, =HORIZONTAL
	BL DRAW_STRAIGHT_LINE

    POP {R0-R12, PC}                ; Pop R4 and return from subroutine
	
DRAW_UP_MIDDLE
	PUSH {R0-R12, LR}			; Push all GPRs and Link Register (LR) onto the stack
	
	MOV R8, #(LINE_LENGTH/2)
	MUL R0, R3, R8
	ADD R1, R0
	LDR R0, =VERTICAL
	BL DRAW_STRAIGHT_LINE

    POP {R0-R12, PC}                ; Pop R4 and return from subroutine
	
	
DRAW_DOWN_MIDDLE
	PUSH {R0-R12, LR}			; Push all GPRs and Link Register (LR) onto the stack
	
	MOV R8, #(LINE_LENGTH/2)
	MUL R0, R3, R8
	SUB R1, R0
	LDR R0, =VERTICAL
	BL DRAW_STRAIGHT_LINE

    POP {R0-R12, PC}                ; Pop R4 and return from subroutine
	

	
DRAW_UP
	PUSH {R0-R12, LR}			; Push all GPRs and Link Register (LR) onto the stack
	
	;R1= center Y
	;R2= center X
	;R3= size
	;R10= color
	
	MOV R8, #LINE_LENGTH
	MUL R0, R3, R8
	ADD R1, R0
	LDR R0, =HORIZONTAL
	BL DRAW_STRAIGHT_LINE
	
	POP {R0-R12, PC}                ; Pop R4 and return from subroutine
	
DRAW_UP_LEFT
	PUSH {R0-R12, LR}			; Push all GPRs and Link Register (LR) onto the stack
	
	MOV R8, #(LINE_LENGTH/2)
	MUL R0, R3, R8
	ADD R1, R0
	MOV R8, #(LINE_LENGTH/2)
	MUL R0, R3, R8
	ADD R2, R0
	LDR R0, =VERTICAL
	BL DRAW_STRAIGHT_LINE
	
	POP {R0-R12, PC}                ; Pop R4 and return from subroutine

DRAW_UP_RIGHT
	PUSH {R0-R12, LR}			; Push all GPRs and Link Register (LR) onto the stack
	
	MOV R8, #(LINE_LENGTH/2)
	MUL R0, R3, R8
	ADD R1, R0
	MOV R8, #(LINE_LENGTH/2)
	MUL R0, R3, R8
	SUB R2, R0
	LDR R0, =VERTICAL
	BL DRAW_STRAIGHT_LINE
	
	POP {R0-R12, PC}                ; Pop R4 and return from subroutine

DRAW_DOWN_LEFT
	PUSH {R0-R12, LR}			; Push all GPRs and Link Register (LR) onto the stack
	
	MOV R8, #(LINE_LENGTH/2)
	MUL R0, R3, R8
	SUB R1, R0
	MOV R8, #(LINE_LENGTH/2)
	MUL R0, R3, R8
	ADD R2, R0
	LDR R0, =VERTICAL
	BL DRAW_STRAIGHT_LINE
	
	POP {R0-R12, PC}                ; Pop R4 and return from subroutine

DRAW_DOWN_RIGHT
	PUSH {R0-R12, LR}			; Push all GPRs and Link Register (LR) onto the stack
	
	MOV R8, #(LINE_LENGTH/2)
	MUL R0, R3, R8
	SUB R1, R0
	MOV R8, #(LINE_LENGTH/2)
	MUL R0, R3, R8
	SUB R2, R0
	LDR R0, =VERTICAL
	BL DRAW_STRAIGHT_LINE
	
	POP {R0-R12, PC}                ; Pop R4 and return from subroutine

DRAW_DOWN
	PUSH {R0-R12, LR}			; Push all GPRs and Link Register (LR) onto the stack
	
	MOV R8, #LINE_LENGTH
	MUL R0, R3, R8
	SUB R1, R0
	LDR R0, =HORIZONTAL
	BL DRAW_STRAIGHT_LINE
	
	POP {R0-R12, PC}                ; Pop R4 and return from subroutine


;#####################################################################################################


DRAW_DIGIT
	PUSH {R0-R12, LR}			; Push all GPRs and Link Register (LR) onto the stack
	;R0= Number
	;R1= center Y
	;R2= center X
	;R3= size
	;R10= color
	
	CMP R0, #9			; Check if x is within range (0-9)
    BHI.W end_num_draw		; Branch if x > 9 (out of range)
	
    LDR R4, =number_branch_table        ; Load the address of the branch table into R4
    LSL R0, R0, #2               ; Multiply R0 (index) by 4 (word size)
    LDR R5, [R4, R0]             ; Load target address from the branch table
    BX R5                        ; Branch to the corresponding number handler
	
number_branch_table
    DCD Number0			  ; Address for case 0
    DCD Number1           ; Address for case 1
    DCD Number2           ; Address for case 2
	DCD Number3           ; Address for case 3
    DCD Number4           ; Address for case 4
	DCD Number5           ; Address for case 5
    DCD Number6           ; Address for case 6
	DCD Number7           ; Address for case 7
    DCD Number8           ; Address for case 8
	DCD Number9           ; Address for case 9
	
Number0
	;CMP R0, #1
	;;BHS Number1
	
	BL DRAW_UP_RIGHT
	BL DRAW_UP_LEFT
	BL DRAW_DOWN_RIGHT
	BL DRAW_DOWN_LEFT
	BL DRAW_UP
	BL DRAW_DOWN
	
	B end_num_draw
	
Number1
	;CMP R0, #2
	;BHS Number2
	
	BL DRAW_UP_MIDDLE
	BL DRAW_DOWN_MIDDLE
	
	B end_num_draw
	
Number2
	;CMP R0, #3
	;BHS Number3
	
	BL DRAW_UP_RIGHT
	BL DRAW_DOWN_LEFT
	BL DRAW_MIDDLE
	BL DRAW_UP
	BL DRAW_DOWN
	
	B end_num_draw
	
Number3
	;CMP R0, #4
	;BHS Number4
	
	BL DRAW_UP_RIGHT
	BL DRAW_DOWN_RIGHT
	BL DRAW_MIDDLE
	BL DRAW_UP
	BL DRAW_DOWN
	
	B end_num_draw
	
Number4
	;CMP R0, #5
	;BHS Number5
	
	BL DRAW_UP_RIGHT
	BL DRAW_UP_LEFT
	BL DRAW_DOWN_RIGHT
	BL DRAW_MIDDLE
	
	B end_num_draw
	
Number5
	;CMP R0, #6
	;BHS Number6
	
	BL DRAW_UP_LEFT
	BL DRAW_DOWN_RIGHT
	BL DRAW_UP
	BL DRAW_MIDDLE
	BL DRAW_DOWN
	
	B end_num_draw
	
Number6
	;CMP R0, #7
	;BHS Number7
	
	BL DRAW_UP
	BL DRAW_UP_LEFT
	BL DRAW_DOWN
	BL DRAW_DOWN_RIGHT
	BL DRAW_DOWN_LEFT
	BL DRAW_MIDDLE
	
	B end_num_draw

Number7
	;CMP R0, #8
	;BHS Number8
	
	BL DRAW_UP_RIGHT
	BL DRAW_UP
	BL DRAW_DOWN_RIGHT

	B end_num_draw
	
Number8
	;CMP R0, #9
	;BHS Number9

	BL DRAW_UP_RIGHT
	BL DRAW_UP_LEFT
	BL DRAW_DOWN_RIGHT
	BL DRAW_DOWN_LEFT
	BL DRAW_UP
	BL DRAW_MIDDLE
	BL DRAW_DOWN
	
	B end_num_draw
	
Number9

	BL DRAW_UP_RIGHT
	BL DRAW_UP_LEFT
	BL DRAW_DOWN_RIGHT
	BL DRAW_UP
	BL DRAW_MIDDLE
	BL DRAW_DOWN

	
end_num_draw	
	POP {R0-R12, PC}                ; Pop R4 and return from subroutine
	
	
	
DRAW_NUM
	PUSH {R0-R12, LR}			; Push all GPRs and Link Register (LR) onto the stack
	;R0= Number
	;R1= center Y
	;R2= center X
	;R3= size
	;R10= color

	
	MOV R8, R0
	LDR R9, =10
	BL Divide
	
	MOV R0, R8
	
	BL DRAW_DIGIT
	
	
	MOV R8, R9
	LDR R9, =10
	BL Divide
	
	MOV R0, R8
	LDR R8, =(LINE_LENGTH*2)
	MUL R8, R3
	ADD R2, R8
	
	BL DRAW_DIGIT
	
	
	POP {R0-R12, PC}                ; Pop R4 and return from subroutine
	
	
	
	
;########################################################################################################################33
	
	
DRAW_LETTER
	PUSH {R4-R9,R11-R12, LR}			; Push all GPRs and Link Register (LR) onto the stack
	;R0= letter
	;R1= center Y
	;R2= center X
	;R3= size
	;R10= color
	
	CMP R0, #67
	BHI.W end_letter_draw
	
    LDR R4, =letter_branch_table      ; Load the address of the branch table into R4
    SUB R0, R0, #67            ; Convert ASCII value to index (A = 0, B = 1, ...)
    LSL R0, R0, #2             ; Multiply index by 4 (word size)
    LDR R5, [R4, R0]           ; Load target address from the branch table
    BX R5                      ; Branch to the corresponding letter handler

; Branch Table (switch-case handlers)
letter_branch_table
    DCD Letter_A                  ; Address for 'A'
    DCD Letter_B                  ; Address for 'B'
    DCD Letter_C                  ; Address for 'C'
    DCD Letter_D                  ; Address for 'D'
    DCD Letter_E                  ; Address for 'E'
    DCD Letter_F                  ; Address for 'F'
    DCD Letter_G                  ; Address for 'G'
    DCD Letter_H                  ; Address for 'H'
    DCD Letter_I                  ; Address for 'I'
    DCD Letter_J                  ; Address for 'J'
    DCD Letter_K                  ; Address for 'K'
    DCD Letter_L                  ; Address for 'L'
    DCD Letter_M                  ; Address for 'M'
    DCD Letter_N                  ; Address for 'N'
    DCD Letter_O                  ; Address for 'O'
    DCD Letter_P                  ; Address for 'P'
	DCD Letter_Q                  ; Address for 'Q'
    DCD Letter_R                  ; Address for 'R'
    DCD Letter_S                  ; Address for 'S'
    DCD Letter_T                  ; Address for 'T'
	
Letter_A
	
	BL DRAW_UP_RIGHT
	BL DRAW_UP_LEFT
	BL DRAW_DOWN_RIGHT
	BL DRAW_DOWN_LEFT
	BL DRAW_UP
	BL DRAW_MIDDLE
	
	B end_letter_draw
	
Letter_B
	
	BL DRAW_UP_RIGHT
	BL DRAW_DOWN_RIGHT
	
	B end_letter_draw
	
Letter_C
	
	BL DRAW_UP_LEFT
	BL DRAW_DOWN_LEFT
	BL DRAW_UP
	BL DRAW_DOWN
	
	B end_letter_draw
	
Letter_D
	
	BL DRAW_UP_RIGHT
	BL DRAW_DOWN_RIGHT
	BL DRAW_MIDDLE
	BL DRAW_UP
	BL DRAW_DOWN
	
	B end_letter_draw
	

Letter_E
	
	BL DRAW_UP_LEFT
	BL DRAW_DOWN_LEFT
	BL DRAW_UP
	BL DRAW_MIDDLE
	BL DRAW_DOWN
	
	B end_letter_draw
	
Letter_F
	
	BL DRAW_UP_LEFT
	BL DRAW_DOWN_LEFT
	BL DRAW_UP
	BL DRAW_MIDDLE
	
	B end_letter_draw
	
Letter_G
	
	BL DRAW_UP_RIGHT
	BL DRAW_DOWN_LEFT
	BL DRAW_MIDDLE
	BL DRAW_UP
	BL DRAW_DOWN
	
	B end_letter_draw
	
Letter_H
	
	BL DRAW_UP_RIGHT
	BL DRAW_UP_LEFT
	BL DRAW_DOWN_RIGHT
	BL DRAW_DOWN_LEFT
	BL DRAW_MIDDLE
	
	B end_letter_draw
	
Letter_I
	
	BL DRAW_UP
	BL DRAW_UP_MIDDLE
	BL DRAW_DOWN_MIDDLE
	BL DRAW_DOWN
	
	B end_letter_draw
	
Letter_J
	
	BL DRAW_UP_RIGHT
	BL DRAW_DOWN_LEFT
	BL DRAW_DOWN_RIGHT
	BL DRAW_DOWN
	
	B end_letter_draw
	
Letter_K
	
	BL DRAW_UP
	BL DRAW_UP_LEFT
	BL DRAW_DOWN
	BL DRAW_DOWN_RIGHT
	BL DRAW_DOWN_LEFT
	BL DRAW_MIDDLE
	
	B end_letter_draw

Letter_L
	
	BL DRAW_UP_LEFT
	BL DRAW_DOWN_LEFT
	BL DRAW_DOWN
	
	B end_letter_draw
	
Letter_M

	BL DRAW_UP_RIGHT
	BL DRAW_UP_LEFT
	BL DRAW_DOWN_RIGHT
	BL DRAW_DOWN_LEFT
	BL DRAW_UP
	BL DRAW_MIDDLE
	BL DRAW_DOWN
	
	B end_letter_draw
	
Letter_N

	BL DRAW_UP_RIGHT
	BL DRAW_UP_LEFT
	BL DRAW_DOWN_RIGHT
	BL DRAW_DOWN_LEFT
	BL DRAW_UP
	BL DRAW_MIDDLE
	BL DRAW_DOWN
	
	B end_letter_draw
	
Letter_O
	BL DRAW_UP_RIGHT
	BL DRAW_UP
	BL DRAW_DOWN_RIGHT
	BL DRAW_DOWN
	BL DRAW_UP_LEFT
	BL DRAW_DOWN_LEFT

	B end_letter_draw
	
Letter_P
	BL DRAW_UP
	BL DRAW_MIDDLE
	BL DRAW_DOWN_LEFT
	BL DRAW_UP_RIGHT
	BL DRAW_UP_LEFT

	B end_letter_draw	
	
Letter_Q

	B end_letter_draw
	
Letter_R
	
	B end_letter_draw
	
Letter_S
	BL DRAW_UP
	BL DRAW_MIDDLE
	BL DRAW_DOWN
	BL DRAW_DOWN_RIGHT
	BL DRAW_UP_LEFT

	B end_letter_draw
	
Letter_T
	BL DRAW_UP
	BL DRAW_UP_MIDDLE
	BL DRAW_DOWN_MIDDLE
	
	B end_letter_draw

	
end_letter_draw	
	POP {R4-R9,R11-R12, PC}			               ; Pop R4 and return from subroutine



; HELPER DELAYS IN THE SYSTEM, YOU CAN USE THEM DIRECTLY



 