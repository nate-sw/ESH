;
; Lab 7 Task 4
; 2023-11-13
; Author : nsw
;

.include "m8515def.inc"
;
; Refer to doc2512.pdf



.equ     BUSON = $80
.equ     ADRR1 = $6FFF


.cseg
reset:   rjmp  init

.org     $16

init:

init_bus:
         LDI   R17, BUSON
         OUT   MCUCR, R17
pt1:
         LDS   R17, ADRR1
         RJMP  pt1





.exit
