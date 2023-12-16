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
.equ     ADCADR = $1000 ; Memory address for ADC
.equ     SVSEGADR = $1800 ; Memory address for 7 segment displays
.equ     ADRR1 = $2000 ; Memory address for LCD's control
.equ     ADRR2 = $2100 ; Memory address for LCD's data

.equ     SecondsAddr = 0x1850 ; Memory address for seconds
.equ     MinutesAddr = 0x2150 ; Memory address for minutes
.equ     HoursAddr   = 0x2151 ; Memory address for hours

;.equ     ClockPulseCntReg = R19 ; Register used to count clock pulses


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
         

         
         


main:    
         RCALL pgm_start

         RCALL  clr ;Use only for troubleshooting startup message

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
         LDI   R21, $FE ;Number of samples to be taken
         CLR   R22 ;Below trim count
         CLR   R23 ;Above trim count
         LDI   R25, $01 ;junk code


         

         

;nodechk:
;         RCALL getch
;         CPI   R16, $41
;         RCALL putchar
;         BRNE  nodechk




node:
         RCALL dly2ms
         STS   ADCADR, R25

adcping:
         IN    R24, PIND
         ANDI  R24, $01
         BREQ  adcping

nodecont:
         LDS   R24, $1000
         ST    x+, R24

         CPI   R24, $80 ;Default trim value - Change later to add logic
         BRLO  ltrim
         
         ;RCALL dly2ms

         RCALL dly2ms ;Used for debugging


         INC   R23
         DEC   R21
         BRNE  node 
         RJMP  node_fini

ltrim:
         RCALL dly2ms
         INC   R22
         DEC   R21
         BRNE  node 
         RJMP  node_fini

node_fini:
         RCALL lcd_line_dw
         RCALL newl
         MOV   R16, R22
         RCALL j_hex2asc
         MOV   R5, R17
         MOV   R4, R16

         MOV   R16, R23
         RCALL j_hex2asc
         MOV   R7, R17
         MOV   R6, R16
         
         LDI   R16, 'L'
         RCALL lcd_puts
         OUT   UDR, R16
         RCALL dly2ms
         LDI   R16, ':'
         RCALL lcd_puts
         OUT   UDR, R16
         RCALL dly2ms
         MOV   R16, R4
         RCALL lcd_puts
         OUT   UDR, R16
         RCALL dly2ms
         MOV   R16, R5
         RCALL lcd_puts
         OUT   UDR, R16
         RCALL dly2ms
         LDI   R16, $20
         RCALL lcd_puts
         OUT   UDR, R16
         RCALL dly2ms
         LDI   R16, 'H'
         RCALL lcd_puts
         OUT   UDR, R16
         RCALL dly2ms
         LDI   R16, ':'
         RCALL lcd_puts
         OUT   UDR, R16
         RCALL dly2ms


         MOV   R16, R6
         RCALL lcd_puts
         OUT   UDR, R16
         RCALL dly200ms
         MOV   R16, R7
         RCALL lcd_puts
         OUT   UDR, R16
         RCALL dly200ms

         RJMP  node_init

clr:
         RCALL lcd_clr
         RCALL dly2ms
         RET

fini:
         RJMP  fini

j_getche:
         RJMP  getche

j_init_uart:
         RJMP  init_uart

j_hex2asc:
         RJMP  hex2asc




msg0:    .db   " DatAQMon_v1.0", $00

msg1:    .db   " 2032574",  $00


svrmsg:  .db   "SVR#", $00
ndemsg:  .db   " NODE>", $00




.include "delays.inc"
.include "lcdio.inc"
.include "startup.inc"
.include "num.inc" 

.include "termio.inc"   ;routines to do terminal io using AVR's USART
.include "numio.inc" 
.exit