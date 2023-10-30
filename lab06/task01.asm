;
; Lab 6 Task 1
; 2023-10-30
; Author : nsw
;

.include "m8515def.inc"
;
; Refer to doc2512.pdf



.equ     BUSON = $80
.equ     VAL   = $5A
.equ     ADRR  = $4321

.cseg
reset:   rjmp  init

.org     $16

init:

init_bus:
         LDI   R17, BUSON
         OUT   MCUCR, R17
         LDI   R17, VAL

pt1:
         STS   ADRR, R17
         RJMP  pt1





.exit
