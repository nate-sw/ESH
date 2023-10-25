;
; Lab 5 Task 11
; 2023-10-16
; Author : nsw
;

.include "m8515def.inc"

; Code based off program originally written by Nick Markou

; Serial port test program
;
; Refer to doc2512.pdf

.dseg

entmsg:  .byte 5

.equ     BAUD  = 25     ;from Table 68 (p.160) & depends on clk speed
.equ     FRAME = $86    ;select data, parity, stop bit (p.156-158)	     
.equ     CHAN  = $18    

.equ     HI    = $F4
.equ     LO    = $24
.equ     CLIM  = 40

.cseg
reset:   rjmp  init

.org     $20
init:		          ;used as an entry point for the reset
         LDI   R16, LOW(RAMEND)
         OUT   SPL, R16
         LDI   R16, HIGH(RAMEND)
         OUT   SPH, R16

         LDI   R27, HIGH(entmsg)
         LDI   R26, LOW(entmsg)        

main:
         
         RCALL dly
         RCALL init_uart
         LDI   R17, 3

msg1init:
         LDI   R31, HIGH(banner1<<1)
         LDI   R30, LOW(banner1<<1)

msg1: 
         LPM   R16, Z+
         CPI   R16, $FF
         BREQ  entermsg
         RCALL outch

         DEC   R17
         BRNE  msg1

entermsg:
         RCALL getch
         RCALL outch

         RCALL chk

         CPI   R16, $0D
         BREQ  modmsg
         ST    X+, R16

         INC   R17
         CPI   R17, CLIM
         BREQ  

chk:
         NOP   ;Check for uppercase, lowercase, convert
         RET

outinit:
         LDI   R31, HIGH(modline<<1)
         LDI   R30, LOW(modline<<1)

out:
         LPM   R16, Z+

         CPI   R16, $FF
         BREQ  modout

         RCALL outch
         RJMP  OUT:

modout:
         LD    R16, -X
         RCALL outch

         DEC   R17
         BRNE  outch

         RJMP  init


getch:
         in    R16, UCSRA
         ANDI  R16, $80
         BREQ  GETCH
         IN    R16, UDR
         RET



init_uart:                 
         ldi   R16, 0	      ;always zero (mostly)
         out   UBRRH, R16    
         ldi   R16, BAUD	 
         out   UBRRL, R16    ;config. Tx baud rate w/equ value 
         ldi   R16, CHAN      
         out   UCSRB, R16    ;enable transmit only (see p.156)
         ldi   R16, FRAME         
         out   UCSRC, R16    ;config. frame elements 		
         RET			

outch:	
         out   UDR, R16		;txmt char. out the TxD 
pollsr:		
         in    R18, UCSRA 	
         andi  R18, $20   	
         breq  pollsr
         RET

dly:
         LDI   R29, HI
         LDI   R28, LO
         LDI   R27, 4

dly4loop:
         LDI   R29, HI
         LDI   R28, LO

dlynstloop:    
         SBIW  R29:R28, 1
         BRNE  dlynstloop
         SUBI  R27, 1
         BRNE  dly4loop

         RET

banner1: .db   "ASCII Scrambler V1", $0A, $0D, 
banner2: .db   "by: Nate Simard-White", $0A, $0D, $0A, $0D
entline: .db   "Enter line", $0A, $0D, ">", $FF
modline: .db   0A, $0D, $0A, $0D, "Modified line", $0A, $0D, ">>"

.exit
