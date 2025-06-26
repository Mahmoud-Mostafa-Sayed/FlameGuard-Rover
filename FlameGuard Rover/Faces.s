	;INCLUDE TimerInit.s
	INCLUDE tft_spi.s
		
	AREA MyCode, CODE, READONLY

	EXPORT Angry_face
	EXPORT Smiley_face
	
Angry_face
	PUSH {R2-R12, LR}
	
	LDR R6, =80
	LDR R7, =240
	LDR R4, =10
	LDR R5, =20
	LDR R10, =RED
	BL DRAW_RECTANGLE_FILLED
	
	LDR R6, =70
	LDR R7, =250
	LDR R4, =20
	LDR R5, =30
	LDR R10, =RED
	BL DRAW_RECTANGLE_FILLED
	
	LDR R6, =60
	LDR R7, =260
	LDR R4, =30
	LDR R5, =40
	LDR R10, =RED
	BL DRAW_RECTANGLE_FILLED
	
	LDR R6, =50
	LDR R7, =250
	LDR R4, =40
	LDR R5, =140
	LDR R10, =RED
	BL DRAW_RECTANGLE_FILLED
	
	LDR R6, =60
	LDR R7, =260
	LDR R4, =140
	LDR R5, =150
	LDR R10, =RED
	BL DRAW_RECTANGLE_FILLED
		
	LDR R6, =70
	LDR R7, =250
	LDR R4, =150
	LDR R5, =160
	LDR R10, =RED
	BL DRAW_RECTANGLE_FILLED
	
	LDR R6, =80
	LDR R7, =240
	LDR R4, =160
	LDR R5, =170
	LDR R10, =RED
	BL DRAW_RECTANGLE_FILLED

	;EYES
	LDR R4, =70        ; Starting Y-coordinate of the eyes
	LDR R5, =110        ; Ending Y-coordinate of the eyes
	LDR R6, =100         ; Starting X-coordinate of eyes
	LDR R7, =120        ; Ending X-coordinate of the eyes
	LDR R10, =BLACK      ; Color for the mouth
	BL DRAW_RECTANGLE_FILLED
	
	LDR R4, =70        ; Starting Y-coordinate of the eyes
	LDR R5, =110        ; Ending Y-coordinate of the eyes
	LDR R6, =180         ; Starting X-coordinate of the eyes
	LDR R7, =200        ; Ending X-coordinate of the eyes
	LDR R10, =BLACK      ; Color for the mouth
	BL DRAW_RECTANGLE_FILLED
	
	;eyebrows left
	LDR R4, =30        ; Starting Y-coordinate of the eyes
	LDR R5, =40        ; Ending Y-coordinate of the eyes
	LDR R6, =90         ; Starting X-coordinate of eyes
	LDR R7, =100        ; Ending X-coordinate of the eyes
	LDR R10, =BLACK      ; Color for the mouth
	BL DRAW_RECTANGLE_FILLED
	LDR R4, =40        ; Starting Y-coordinate of the eyes
	LDR R5, =50        ; Ending Y-coordinate of the eyes
	LDR R6, =100         ; Starting X-coordinate of eyes
	LDR R7, =110        ; Ending X-coordinate of the eyes
	LDR R10, =BLACK      ; Color for the mouth
	BL DRAW_RECTANGLE_FILLED
	LDR R4, =50        ; Starting Y-coordinate of the eyes
	LDR R5, =60        ; Ending Y-coordinate of the eyes
	LDR R6, =110         ; Starting X-coordinate of eyes
	LDR R7, =120        ; Ending X-coordinate of the eyes
	LDR R10, =BLACK      ; Color for the mouth
	BL DRAW_RECTANGLE_FILLED
	LDR R4, =60        ; Starting Y-coordinate of the eyes
	LDR R5, =70        ; Ending Y-coordinate of the eyes
	LDR R6, =120         ; Starting X-coordinate of eyes
	LDR R7, =130        ; Ending X-coordinate of the eyes
	LDR R10, =BLACK      ; Color for the mouth
	BL DRAW_RECTANGLE_FILLED
	;right
	LDR R4, =30        ; Starting Y-coordinate of the eyes
	LDR R5, =40        ; Ending Y-coordinate of the eyes
	LDR R6, =210         ; Starting X-coordinate of eyes
	LDR R7, =220        ; Ending X-coordinate of the eyes
	LDR R10, =BLACK      ; Color for the mouth
	BL DRAW_RECTANGLE_FILLED
	LDR R4, =40        ; Starting Y-coordinate of the eyes
	LDR R5, =50        ; Ending Y-coordinate of the eyes
	LDR R6, =200         ; Starting X-coordinate of eyes
	LDR R7, =210        ; Ending X-coordinate of the eyes
	LDR R10, =BLACK      ; Color for the mouth
	BL DRAW_RECTANGLE_FILLED
	LDR R4, =50        ; Starting Y-coordinate of the eyes
	LDR R5, =60        ; Ending Y-coordinate of the eyes
	LDR R6, =190         ; Starting X-coordinate of eyes
	LDR R7, =200       ; Ending X-coordinate of the eyes
	LDR R10, =BLACK      ; Color for the mouth
	BL DRAW_RECTANGLE_FILLED
	LDR R4, =60        ; Starting Y-coordinate of the eyes
	LDR R5, =70        ; Ending Y-coordinate of the eyes
	LDR R6, =180         ; Starting X-coordinate of eyes
	LDR R7, =190        ; Ending X-coordinate of the eyes
	LDR R10, =BLACK      ; Color for the mouth
	BL DRAW_RECTANGLE_FILLED
	
	; === Mouth (Black Rectangle) ===
	LDR R4, =150        ; Starting Y-coordinate of the mouth
	LDR R5, =160        ; Ending Y-coordinate of the mouth
	LDR R6, =100         ; Starting X-coordinate of the mouth
	LDR R7, =110        ; Ending X-coordinate of the mouth
	LDR R10, =BLACK      ; Color for the mouth
	BL DRAW_RECTANGLE_FILLED
	
	LDR R4, =140        ; Starting Y-coordinate of the mouth
	LDR R5, =150        ; Ending Y-coordinate of the mouth
	LDR R6, =110         ; Starting X-coordinate of the mouth
	LDR R7, =210        ; Ending X-coordinate of the mouth
	LDR R10, =BLACK      ; Color for the mouth
	BL DRAW_RECTANGLE_FILLED

	LDR R4, =150        ; Starting Y-coordinate of the mouth
	LDR R5, =160        ; Ending Y-coordinate of the mouth
	LDR R6, =200         ; Starting X-coordinate of the mouth
	LDR R7, =210        ; Ending X-coordinate of the mouth
	LDR R10, =BLACK      ; Color for the mouth
	BL DRAW_RECTANGLE_FILLED
	
	POP {R2-R12, PC}
	
	BX LR
	

Smiley_face	
	PUSH {R2-R12, LR}
	
	LDR R6, =80
	LDR R7, =240
	LDR R4, =10
	LDR R5, =20
	LDR R10, =YELLOW
	BL DRAW_RECTANGLE_FILLED
	
	LDR R6, =70
	LDR R7, =250
	LDR R4, =20
	LDR R5, =30
	LDR R10, =YELLOW
	BL DRAW_RECTANGLE_FILLED
	
	LDR R6, =60
	LDR R7, =260
	LDR R4, =30
	LDR R5, =40
	LDR R10, =YELLOW
	BL DRAW_RECTANGLE_FILLED
	
	LDR R6, =50
	LDR R7, =250
	LDR R4, =40
	LDR R5, =140
	LDR R10, =YELLOW
	BL DRAW_RECTANGLE_FILLED
	
	LDR R6, =60
	LDR R7, =260
	LDR R4, =140
	LDR R5, =150
	LDR R10, =YELLOW
	BL DRAW_RECTANGLE_FILLED
		
	LDR R6, =70
	LDR R7, =250
	LDR R4, =150
	LDR R5, =160
	LDR R10, =YELLOW
	BL DRAW_RECTANGLE_FILLED
	
	LDR R6, =80
	LDR R7, =240
	LDR R4, =160
	LDR R5, =170
	LDR R10, =YELLOW
	BL DRAW_RECTANGLE_FILLED

	;EYES
	LDR R4, =70        ; Starting Y-coordinate of the mouth
	LDR R5, =110        ; Ending Y-coordinate of the mouth
	LDR R6, =100         ; Starting X-coordinate of the mouth
	LDR R7, =120        ; Ending X-coordinate of the mouth
	LDR R10, =BLACK      ; Color for the mouth
	BL DRAW_RECTANGLE_FILLED
	
	LDR R4, =70        ; Starting Y-coordinate of the mouth
	LDR R5, =110        ; Ending Y-coordinate of the mouth
	LDR R6, =180         ; Starting X-coordinate of the mouth
	LDR R7, =200        ; Ending X-coordinate of the mouth
	LDR R10, =BLACK      ; Color for the mouth
	BL DRAW_RECTANGLE_FILLED
	
	; === Mouth (Black Rectangle) ===
	LDR R4, =130        ; Starting Y-coordinate of the mouth
	LDR R5, =140        ; Ending Y-coordinate of the mouth
	LDR R6, =100         ; Starting X-coordinate of the mouth
	LDR R7, =110        ; Ending X-coordinate of the mouth
	LDR R10, =BLACK      ; Color for the mouth
	BL DRAW_RECTANGLE_FILLED
	
	LDR R4, =140        ; Starting Y-coordinate of the mouth
	LDR R5, =150        ; Ending Y-coordinate of the mouth
	LDR R6, =110         ; Starting X-coordinate of the mouth
	LDR R7, =210        ; Ending X-coordinate of the mouth
	LDR R10, =BLACK      ; Color for the mouth
	BL DRAW_RECTANGLE_FILLED

	LDR R4, =130        ; Starting Y-coordinate of the mouth
	LDR R5, =140        ; Ending Y-coordinate of the mouth
	LDR R6, =200         ; Starting X-coordinate of the mouth
	LDR R7, =210        ; Ending X-coordinate of the mouth
	LDR R10, =BLACK      ; Color for the mouth
	BL DRAW_RECTANGLE_FILLED
	
	POP {R2-R12, PC}
	BX LR