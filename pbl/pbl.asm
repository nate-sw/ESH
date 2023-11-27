;
; PBL
; 2023-11-27
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


.equ     BAUD  = 25     ;from Table 68 (p.160) & depends on clk speed
.equ     FRAME = $86    ;select data, parity, stop bit (p.156-158)	     
.equ     CHAN = 0x18    ;channel enable (Tx only for now)

init0:         ;Initialize stack pointer.
         LDI   R16, LOW(RAMEND)
         OUT   SPL, R16
         LDI   R16, HIGH(RAMEND)
         OUT   SPH, R16

init1:
         LDI   R16, BUSON
         OUT   MCUCR, R16
         

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

init_uart:                 
         ldi   R16, 0	      ;always zero (mostly)
         out   UBRRH, R16    
         ldi   R16, BAUD	 
         out   UBRRL, R16    ;config. Tx baud rate w/equ value 
         ldi   R16, CHAN      
         out   UCSRB, R16    ;enable transmit only (see p.156)
         ldi   R16, FRAME         
         out   UCSRC, R16    ;config. frame elements 



init_msg:
         LDI   R31, HIGH(initmsg<<1)
         LDI   R30, LOW(initmsg<<1)
         LDI   R18, 2

main:    

         LPM   R17, Z+
         CPI   R17, $0D
         BREQ  lcd_chline
         CPI   R17, $20
         BREQ  init_ld
         RCALL both_puts
         RCALL dly
         RJMP  main


lcd_chline:
         DEC   R18
         BREQ  main
         LDI   R16, $C0
         STS   ADRR1, R16
         RCALL dly
         RJMP  main

fini:
         RJMP  fini

lcd_puts:
         STS   ADRR2, R17

both_puts:
         STS   ADRR2, R17
         OUT   UDR, R17

dly:
         LDI   R29, HI
         LDI   R28, LO
         

dlynstloop:    
         SBIW  R29:R28, 1
         BRNE  dlynstloop
         RET



ld_main:
         LPM   R17, Z+
         CPI   R17, $00
         BREQ  fini
         RCALL lcd_puts
         RCALL dly
         RJMP  ld_main



init_ld:
         LDI   R16, $0C
         STS   ADRR1, R16
         RCALL dly
         
         LDI   R31, HIGH(lcdldmsg<<1)
         LDI   R30, LOW(lcdldmsg<<1)


         RJMP  ld_main


initmsg:       .db   "DatAQMon_v1.0", $0D, "2032574", $20
lcdldmsg:      .db   $20, $2E, $A5, $DF, $2A, $00 ;Ka boom!