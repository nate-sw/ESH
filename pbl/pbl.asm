;
; PBL
; 2023-11-27
; Author : nsw
;

.include "m8515def.inc"
;
; Refer to doc2512.pdf
; Changelog:
;
; 2023-12-11:  Reworked program startup and LCD display code.


.dseg
min:	.byte 1
tenmin:	.byte 1
hrs:	.byte 1
tenhrs:	.byte 1

samples:.byte 1

.cseg

.equ     BUSON = $80
.equ     ADCADR = $1000


;passed to termio.inc
.equ FCPU_L  = 1000000 ;used by termio rtn 
.equ BAUD  = 2400    ;desired baud rate


init0:
         LDI   R16, LOW(RAMEND) ;Initialize stack pointer.
         OUT   SPL, R16
         LDI   R16, HIGH(RAMEND)
         OUT   SPH, R16
         LDI   R16, $FE 
         OUT   DDRB, R16 ;config PB0 as input
         OUT   DDRD, R16 ;config PD0 as input
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
         
init_msg0:
         LDI   R31, HIGH(msg0<<1)
         LDI   R30, LOW(msg0<<1)
         RCALL dly2ms
         CLR   R16

startup:
         RCALL newl
         CLR   R16
         RCALL lcd_line_up
         RCALL msg_dsp
         RCALL newl
         CLR   R16
         RCALL lcd_line_dw
         LDI   R31, HIGH(msg1<<1)
         LDI   R30, LOW(msg1<<1)
         RCALL dly50usi
         RCALL msg_dsp
         RCALL dly4s

         RCALL  clr ;Use only for troubleshooting startup message

main:    
         RJMP  node_msg




msg_dsp:
         LPM   R16, Z+
         CPI   R16, $00
         BREQ  msg_ret
         RCALL lcd_puts
         RCALL putchar
         
         
         RCALL dly10ms
         RCALL dly50msi
         RJMP  msg_dsp

msg_ret:
         RET

; insert lcd_puts here for debuging




; insert delays here for debuging

node_msg:
         LDI   R31, HIGH(ndemsg<<1)
         LDI   R30, LOW(ndemsg<<1)
         RCALL dly50usi
         RCALL newl
         RCALL lcd_line_up         
         RCALL msg_dsp

         ;RJMP  node_fini ;Use only for troubleshooting node start message

node_init:
         LDI   R27, HIGH(samples)
         LDI   R26, LOW(samples)
         LDI   R21, 255 ;Number of samples to be taken
         CLR   R22 ;Below trim count
         CLR   R23 ;Above trim count
         CLR   R25
         

node:
         RCALL dly2ms
         STS   ADCADR, R25
         IN    R24, PIND
         NOP
         LDS   R24, ADCADR
         ST    x+, R24
         CPI   R24, $80 ;Default trim value - Change later to add logic
         BRLO  ltrim
         INC   R23
         DEC   R21
         BRNE  node 
         RJMP  node_fini

ltrim:
         INC   R22
         DEC   R21
         BRNE  node 
         RJMP  node_fini

node_fini:
         RCALL lcd_line_dw
         RCALL newl
         MOV   R16, R22
         RCALL hex2asc
         MOV   R25, R17
         MOV   R24, R16

         MOV   R16, R23
         RCALL hex2asc
         MOV   R18, R16
         
         LDI   R16, 'L'
         RCALL puts
         RCALL lcd_puts
         LDI   R16, ':'
         RCALL puts
         RCALL lcd_puts   
         MOV   R16, R25
         RCALL puts
         RCALL lcd_puts
         MOV   R16, R24
         RCALL puts
         RCALL lcd_puts
         LDI   R16, $20
         RCALL puts
         RCALL lcd_puts
         LDI   R16, 'H'
         RCALL puts
         RCALL lcd_puts
         LDI   R16, ':'
         RCALL puts
         RCALL lcd_puts   
         MOV   R16, R17
         RCALL puts
         RCALL lcd_puts
         MOV   R16, R18
         RCALL puts
         RCALL lcd_puts

         RJMP  fini

clr:
         RCALL lcd_clr
         RCALL dly2ms
         RET

fini:
         RJMP  fini


j_init_uart:
         RJMP  init_uart



msg0:    .db   " DatAQMon_v1.0", $00

msg1:    .db   " 2032574",  $00


svrmsg:  .db   "SVR#", $00
ndemsg:  .db   " NODE>", $00




.include "delays.inc"
.include "lcdio.inc"
.include "termio.inc"   ;routines to do terminal io using AVR's USART
.include "numio.inc" 
.exit