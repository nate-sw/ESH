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

.equ     BAUD  = 25     ;from Table 68 (p.160) & depends on clk speed
.equ     FRAME = $86    ;select data, parity, stop bit (p.156-158)	     
.equ     CHAN  = $18    

.equ     HI    = $F4
.equ     LO    = $24

.cseg
reset:   rjmp  init

.org     $20
init:		          ;used as an entry point for the reset
	nop
         LDI   R16, LOW(RAMEND)
         OUT   SPL, R16
         LDI   R16, HIGH(RAMEND)
         OUT   SPH, R16
         

init_ports:				
         ldi   R18, 0x0F	  ;set PE2:PE0 as output
         out   DDRE, R18
;---------------------------------------------------
;

main:
         LDI   R31, HIGH(msg1<<1)
         LDI   R30, LOW(msg1<<1)
         RCALL dly
         RCALL init_uart
         LDI   R17, 3

looptx: 
         CLR   R18
         LPM   R16, Z+
         ADD   R18, R16
         RCALL outch

         CPI   R18, $0D
         BRNE  looptx

         DEC   R17
         BRNE  looptx
         RJMP  main

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
         in    R16, UCSRA 	
         andi  R16, $20   	
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

msg1:    .db   "Lab 05", $0A, $0D
msg2:    .db   "Nate Simard-White", $0A, $0D
msg3:    .db   "2023-10-16", $0A, $0D

.exit
