;
; PBL
; 2023-11-27
; Author : nsw
;

.include "m8515def.inc"
;
; Refer to doc2512.pdf

.dseg
min:	.byte 1
tenmin:	.byte 1
hrs:	.byte 1
tenhrs:	.byte 1

.cseg

.equ     BUSON = $80



;passed to termio.inc
.equ FCPU_L  = 1000000 ;used by termio rtn 
.equ BAUD  = 2400    ;desired baud rate


init0:
         LDI   R16, LOW(RAMEND) ;Initialize stack pointer.
         OUT   SPL, R16
         LDI   R16, HIGH(RAMEND)
         OUT   SPH, R16

         LDI   R16, $00 
         OUT   DDRB, R16 ;config PB0 as input

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
         RCALL lcd_ent_md
         RCALL dly50usi

         
init_msg:
         LDI   R31, HIGH(initmsg<<1)
         LDI   R30, LOW(initmsg<<1)

         LDI   R18, 2
         ;LDI   R20, 0
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
         BREQ  main ;changes lines once $00 is read twice
         RCALL lcd_line_dw

         LDI   R17, $0A
         RCALL term_puts
         RCALL dly50usi
         RJMP  main

; insert lcd_puts here for debuging

term_puts:
         OUT   UDR, R17
         RET


; insert delays here for debuging


init_ld:
         LDI   R31, HIGH(lcdldmsg<<1)
         LDI   R30, LOW(lcdldmsg<<1)

ld_main:
         LPM   R17, Z+
         CPI   R17, $00
         BREQ  svr_init ;PB0_chk
         RCALL lcd_puts
         RCALL term_puts

         
         RCALL dly1s
         RJMP  ld_main


PB0_chk:
;         IN    R16, PINB
;         ANDI  R16, $01

;         CPI   R16, $01
;         BREQ  nde_init


svr_init:
         
         LDI   R31, HIGH(svrmsg<<1)
         LDI   R30, LOW(svrmsg<<1)
         RCALL lcd_line_up
         
svr_top:
         LPM   R17, Z+
         CPI   R17, $00
         BREQ  svr_bottom
         RCALL lcd_puts
         RCALL term_puts
         RCALL dly50usi
         RJMP  svr_top

svr_bottom:
         RCALL lcd_line_dw
         LDI   R16, 0
         STS   min, R16
         STS   tenmin, R16
         STS   hrs, R16
         STS   tenhrs, R16
         


svr_loop:
         RCALL lcd_line_dw
         RCALL dly50usi
         LDS   R17, tenhrs
         RCALL lcd_puts
         RCALL dly50usi
         LDS   R17, hrs
         RCALL lcd_puts
         RCALL dly50usi
         LDS   R17, tenmin
         RCALL lcd_puts
         RCALL dly50usi
         LDS   R17, min
         RCALL lcd_puts
         RJMP  minloop


thrsloop:
         RCALL svr_loop
         STS   hrs, R16
         LDS   R23, tenhrs
         INC   R23
         CPI   R23, 2
         BREQ  thrs20loop
         STS   hrs, R23
         RJMP  minloop

thrs20loop:
         STS   hrs, R23
         CPI   R22, 4
         BREQ  svr_bottom

hrsloop:
         RCALL svr_loop
         STS   tenmin, R16
         LDS   R22, hrs
         INC   R22
         CPI   R22, 10
         BREQ  thrsloop
         STS   hrs, R22
         RJMP  minloop

tminloop:
         RCALL svr_loop
         STS   min, R16
         LDS   R21, tenmin
         INC   R21
         CPI   R21, 6
         BREQ  hrsloop
         STS   tenmin, R21
         RJMP  minloop

minloop:
         RCALL svr_loop
         LDS   R20, min
         INC   R20
         CPI   R20, 10
         BREQ  tminloop
         STS   min, R20
         RCALL dly10s
         RJMP  minloop


;nde_init:
;         RCALL lcd_clr
;         RCALL dly2ms


;nde_mode:



clr:
         RCALL lcd_clr
         RCALL dly2ms


fini:
         RJMP  fini


j_init_uart:
         RJMP  init_uart

         

initmsg:       .db   $0D, "DatAQMon_v1.0", $00, $0D,  "2032574", $20
lcdldmsg:      .db   $20, "LOAD", $00

svrmsg:        .db "SVR#", $00



.include "delays.inc"
.include "lcdio.inc"
.include "termio.inc"   ;routines to do terminal io using AVR's USART
.exit