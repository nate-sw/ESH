;
; Lab 8 Task 2.2
; 2023-11-20
; Author : nsw
;

.include "m8515def.inc"
;
; Refer to doc2512.pdf



.equ     BUSON = $80
.equ     VAL   = $38
.equ     ADRR1 = $2000
.equ     HI    = $F4
.equ     LO    = $24

init:
         LDI   R16, BUSON
         OUT   MCUCR, R16
         LDI   R16, LOW(RAMEND)
         OUT   SPL, R16
         LDI   R16, HIGH(RAMEND)
         OUT   SPH, R16

init_lcd:
         

         LDI   R16, VAL
         STS   ADRR1, R16
         RCALL dly

         LDI   R16, VAL
         STS   ADRR1, R16
         RCALL dly

         LDI   R16, $0F
         STS   ADRR1, R16
         RCALL dly

         LDI   R16, $06
         STS   ADRR1, R16
         RCALL dly

         
fini:
         RJMP  fini
dly:
         LDI   R29, HI
         LDI   R28, LO

dlynstloop:    
         SBIW  R29:R28, 1
         BRNE  dlynstloop
         RET