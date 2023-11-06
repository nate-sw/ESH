;
; Lab 6 Task 11
; 2023-11-06
; Author : nsw
;

.include "m8515def.inc"
;
; Refer to doc2512.pdf



.equ     BUSON = $80
.equ     VAL   = $96
.equ     ADRR1 = $2000
.equ     ADRR2 = $4000

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

         
         RJMP  pt1





.exit
