;
; Lab 5 Task 9
; 2023-10-16
; Author : nsw
;

.include "m8515def.inc"

; Code based off program originally written by Nick Markou

; Serial port test program
;
; Refer to doc2512.pdf

.equ     LTR   = 'N'    ;ASCII test letter
.equ     BAUD  = 25     ;from Table 68 (p.160) & depends on clk speed
.equ     FRAME = $86    ;select data, parity, stop bit (p.156-158)	     
.equ     CHAN = 0x18    ;channel enable (Tx only for now)

.cseg
reset:   rjmp  init

.org     $20
init:		          ;used as an entry point for the reset
	nop
         LDI   R16, LOW(RAMEND)
         OUT   SPL, R16
         LDI   R16, HIGH(RAMEND)
         OUT   SPH, R16
;	      
         

init_ports:				
         ldi   R18, 0x0F	  ;set PE2:PE0 as output
         out   DDRE, R18
;---------------------------------------------------
;

main:
         RCALL init_uart
         clr   R17   ;clear R17 and use for rest of program

; Generate sync pulse to trigger scope before sending character
;--------		  
looptx: 
         out   PORTE, R17       ;toggle low/high/low 
         out   PORTE, R18	    ;
         out   PORTE, R17       ; 
;
         ldi   R16, LTR       ;load R16 with test char.
         RCALL outch
;
;--------

pollsr:		
         in    R16, UCSRA 	
         andi  R16, $20   	
         breq  pollsr
;--------
         rjmp  looptx

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


; Transmit character stored in R16 
; 
outch:	
         out   UDR, R16		;txmt char. out the TxD 
         RET
.exit

