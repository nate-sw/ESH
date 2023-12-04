;
; Filename: termio.inc
; 
; The following code supplied to the Fall 2018 243-513-DW students for educational/study
; purposes. The use of these routines, in whole or in part, without proper reference to 
; origin is a violation of ISEP regarding Academic Integrity and Plagerism.
;
;Description: Subroutine framework for use in the project (do not modify) 
;
;Author: Mr. Markou
;
;Changelog:
;0v9 11/04/17 - beta version of serialio.asm
;1v0 11/10/17 - finalized and commented version 
;2v0 11/11/18 - forked into this version with extra routines
;2v1 11/12/18 - restructured for multi device usability e.g.UART/LCD
;2v2 11/20/18 - added some bells and whistles, and cookie (find it).
;
.equ  UBRR  = (FCPU_L /(16 * BAUD)) -1   ;see p.138 (important)	
.equ  FRAME = $86      ;8N1 standard frame
.equ  TXE = $18        ;Transmit & receive enable     
.equ  LF = $0A		   ;ASCII line feed
.equ  CR = $0D		   ;ASCII carriage return
.equ  NUL = 0	       ;string terminating value
.equ  EOL = 0	       ;string terminating value
.equ  EOT = $04	       ;string terminating value

;
; Standard USART init which logically belongs here
; 
init_uart:                 
	ldi R16, 0	       ;always zero (mostly)
	out UBRRH, R16    
	ldi R16, UBRR	 
	out UBRRL, R16     ;config. the rate of data tx 
	ldi R16, TXE      
	out UCSRB, R16     ;enable port tx (see p.158)
	ldi R16, FRAME     ;defined in calling     
	out UCSRC, R16     ;config. frame elements 
	ret
;
;*gets - asm workalike C routine which inputs from UART RxD
; Entry: Z reg must point to buffer  
;        R17 must contain the size of the buffer.
gets:
	dec   R17	       ;leave room for NUL w/o exceeding buffer limit
gtx: 
    rcall getche
	st	  Z+, R16
	cpi	  R16, CR      ;check for returm
	breq  gty
	dec	  R17
	brne  gtx
gty:
	ldi   R16, NUL     ;place end of string
	st    Z, R16	
	ret
;
;*getch - asm workalike C routine to receive char from UART
; Exit:  R16 contain rx char
getch:
	in    R16,UCSRA
	andi  R16, $80
	breq  getch		   ;poll status for key press
	in	  R16,UDR      ;get char from UART 
	ret
;
;*getche - like above but w/echo
; Exit:  R16 contain rx char
getche:
	rcall getch
	push  R16          ;save R16 on stack
	rcall putchar
	pop  R16           ;and retrieve it back
	ret
;
;*putchar - char tx UART routine 
; Entry: R16  char. to send
putchar:	
    out  UDR,R16	   ;txmt char. out the TxD 
putc1:		
    in   R16, UCSRA    ;poll status reg
	andi R16, $20      ;check for tx complete
	breq putc1
	ret	
;
;*puts - asm workalike routine to puts() in C
; Entry: Z index points to an NUL terminated string in cseg or dseg
puts:
	lpm   R16, Z+      ;get char from memory
	cpi   R16, NUL     
	breq  px		   ;this is the end, my only friend, the end
	rcall putchar      ;send it to uart
	rjmp  puts
px: ret
;
;*newl - issues a new line (CR&LF) which comes in handy 
; Entry: R16
newl:
	ldi   R16, LF	    ;nothing new here
    rcall putchar
	ldi   R16, CR	 
    rcall putchar
	ret	

;
;//insert following two directives to main program a line before .exit
;.nolist
;.include "termio.inc"   ;append library subroutines from same folder

