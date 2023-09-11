;
; lab1-5.asm
;
; Created: 8/28/2023 3:53:23 PM
; Author : 2032574
;


; Replace with your application code
start:
	LDI R16, 127
	LDI R17, 1	
	ADD R16, R17

fini:
	rjmp fini 
	