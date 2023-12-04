;
; PBL
; 2023-11-27
; Author : nsw
;

.include "m8515def.inc"
;
; Refer to doc2512.pdf



.equ     BUSON = $80
.equ     HI    = $F4
.equ     LO    = $24


;passed to termio.inc
.equ FCPU_L  = 1000000 ;used by termio rtn 
.equ BAUD  = 2400    ;desired baud rate


init0:
         LDI   R16, LOW(RAMEND) ;Initialize stack pointer.
         OUT   SPL, R16
         LDI   R16, HIGH(RAMEND)
         OUT   SPH, R16

         RCALL j_init_uart

init_bus:
         LDI   R16, BUSON
         OUT   MCUCR, R16
         

init_lcd:
         RCALL dly50msi

         RCALL fctn_set
         RCALL dly50usi

         RCALL fctn_set
         RCALL dly50usi

         RCALL lcd_on
         RCALL dly50usi

         RCALL lcd_clr
         RCALL dly2ms

         RCALL ent_md
         RCALL dly50usi

         
init_msg:
         LDI   R31, HIGH(initmsg<<1)
         LDI   R30, LOW(initmsg<<1)

         LDI   R18, 2
         LDI   R20, 0
         LDI   R17, $0A
         RCALL term_puts
         RCALL dly50usi

main:    
         LPM   R17, Z+
         CPI   R17, $00
         BREQ  lcd_chline
         CPI   R17, $20
         BREQ  init_ld
         RCALL lcd_puts
         RCALL term_puts
         RCALL dly500ms
         RJMP  main


lcd_chline:
         DEC   R18
         BREQ  main
         LDI   R16, $C0
         STS   ADRR1, R16

         LDI   R17, $0A
         RCALL term_puts
         RCALL dly50usi
         RJMP  main

fini:
         RJMP  fini

; insert lcd_puts here for debuging

term_puts:
         OUT   UDR, R17
         RET


; insert delays here for debuging


init_ld:
         LDI   R16, $0C
         STS   ADRR1, R16


         RCALL dly50usi
         
         LDI   R31, HIGH(lcdldmsg<<1)
         LDI   R30, LOW(lcdldmsg<<1)

ld_main:
         LPM   R17, Z+
         CPI   R17, $00
         BREQ  fini
         RCALL lcd_puts
         RCALL term_puts

         
         RCALL dly1s
         RJMP  ld_main






j_init_uart:
         RJMP  init_uart

         

initmsg:       .db   $0D, "DatAQMon_v1.0", $00, $0D,  "2032574", $20
lcdldmsg:      .db   $20, "LOAD"


.include "delays.inc"
.include "lcdio.inc"
.include "termio.inc"   ;routines to do terminal io using AVR's USART
.exit