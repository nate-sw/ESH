;
; Lab 6 Task 16
; 2023-11-06
; Author : nsw
;

.include "m8515def.inc"
;
; Refer to doc2512.pdf



.equ     BUSON = $80
.equ     VAL   = $96
.equ     ADRR1 = $1000
.equ     ADRR2 = $2000
.equ     ADRR3 = $4000
.equ     ADRR4 = $6000
.equ     ADRR5 = $8000
.equ     ADRR6 = $A000
.equ     ADRR7 = $C000
.equ     ADRR8 = $E000

.cseg
reset:   rjmp  init

.org     $16

init:

init_bus:
         LDI   R17, BUSON
         OUT   MCUCR, R17
         LDI   R17, VAL
pt1:
         STS   ADRR1, R17
         STS   ADRR2, R17
         STS   ADRR3, R17
         STS   ADRR4, R17
         STS   ADRR5, R17
         STS   ADRR6, R17
         STS   ADRR7, R17
         STS   ADRR8, R17

         
         RJMP  pt1





.exit
