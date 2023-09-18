;
; Lab 2 Task 2
; 2023-09-11
; Author : nsw
;
.dseg

.org $200
val1:	.byte 1
val2:	.byte 1
val3:   .byte 1
val4:   .byte 1
val5:   .byte 1

.cseg
reset: rjmp start

.org $32
start:

	LDI  R21, $FF
	OUT  DDRA, R21    
	
	LDI  R16, $55
	STS	 val1, R16
    LDI  R16, $24
	STS  val2, R16
    LDI  R16, $AA
    STS  val3, R16
    LDI  R16, $81
    STS  val4, R16
    LDI  R16, $00
    STS  val5, R16

loop:
    LDS  R16, val1
	OUT  PORTA, R16
    LDS  R16, val2
	OUT  PORTA, R16
    LDS  R16, val3
	OUT  PORTA, R16
    LDS  R16, val4
	OUT  PORTA, R16
    LDS  R16, val5
	OUT  PORTA, R16


fini:
	rjmp loop