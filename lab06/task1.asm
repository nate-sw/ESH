;
; Lab 6 Task 1?
; 2023-10-23
; Author : nsw
;

.include "m8515def.inc"

; Code based off program originally written by Nick Markou

; Serial port test program
;
; Refer to doc2512.pdf

.dseg
tickcnt: .byte 1

.equ     BAUD  = 25     ;from Table 68 (p.160) & depends on clk speed
.equ     FRAME = $86    ;select data, parity, stop bit (p.156-158)	     
.equ     CHAN  = $18    

.equ     HI    = $F4
.equ     LO    = $24

.cseg
reset:   rjmp  init
int_0:   rjmp  isr0

.org     $16

init:
         NOP
         LDI   R16, LOW(RAMEND)
         OUT   SPL, R16
         LDI   R16, HIGH(RAMEND)
         OUT   SPH, R16


init_uart:                 
         LDI   R16, 0	      ;always zero (mostly)
         OUT   UBRRH, R16    
         LDI   R16, BAUD	 
         OUT   UBRRL, R16    ;config. Tx baud rate w/equ value 
         LDI   R16, CHAN      
         OUT   UCSRB, R16    ;enable transmit only (see p.156)
         LDI   R16, FRAME         
         OUT   UCSRC, R16    ;config. frame elements 		
         RET

init_int:                 
         LDI   R16, $40	      
         OUT   GICR, R16
         LDI   R16, $03
         OUT   MCUCR, R16
         
         LDI   R16, $30
         STS   tickcnt, R16
         SEI

main:
         NOP
         RCALL dly
         RJMP  main

isr0:
         PUSH  R16
         LDS   R16, tickcnt
         INC   R16
         CPI   R16, 40
         BREQ  zero_dis_cnt
         RCALL outch
         OUT   UDR, R16
         STS   tickcnt, R16

done_int0:
         POP   R16
         RETI

zero_dis_cnt:
         LDI   R16, $30
         STS   tickcnt, R16
         RCALL outch
         OUT   UDR, R16
         RJMP  done_int0

outch:
         LPM   R18, Z+
         OUT   UDR, R18		;txmt char. out the TxD 
         CPI   R18, $3D
         BRNE  outch
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

msg1:    .db   $0A, $0D, "Second = "


.exit
