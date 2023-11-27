;
; Lab 8 Task 2.4
; 2023-11-20
; Author : nsw
;

.include "m8515def.inc"
;
; Refer to doc2512.pdf



.equ     BUSON = $80
.equ     VAL   = $38
.equ     ADRR1 = $2000
.equ     ADRR2 = $2100
.equ     HI    = $F4
.equ     LO    = $24

init:
         LDI   R16, BUSON
         OUT   MCUCR, R16
         LDI   R16, LOW(RAMEND)
         OUT   SPL, R16
         LDI   R16, HIGH(RAMEND)
         OUT   SPH, R16

         LDI   R18, 2

init_lcd:
         LDI   R16, VAL
         STS   ADRR1, R16
         RCALL dly

         LDI   R16, VAL
         STS   ADRR1, R16
         RCALL dly

         LDI   R16, $0F ;Turn display on, cursor and position on
         STS   ADRR1, R16
         RCALL dly

         LDI   R16, $01 ;clear display
         STS   ADRR1, R16 
         RCALL dly

         LDI   R16, $06 ;entry mode
         STS   ADRR1, R16 
         RCALL dly


msg_init:
         LDI   R31, HIGH(msg1<<1)
         LDI   R30, LOW(msg1<<1)

main:     
         LPM   R17, Z+
         CPI   R17, $00
         BREQ  lcd_chline
         RCALL lcd_puts
         RCALL dly
         RJMP  main


lcd_chline:
         DEC   R18
         BREQ  fini
         LDI   R16, $C0
         STS   ADRR1, R16
         RCALL dly
         RJMP  main



fini:
         RJMP  fini

lcd_puts:
         STS   ADRR2, R17
         RET

dly:
         LDI   R29, HI
         LDI   R28, LO

dlynstloop:    
         SBIW  R29:R28, 1
         BRNE  dlynstloop
         RET



msg1:    .db   "Nate", $00, "2032574", $00