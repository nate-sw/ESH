;
;Example application which uses provided include files 
;Modify (remaove/add) to main() and your include files which 
;contain related subroutines (e.g.lcd display routines) 
;to accomplish project goals. Whole idea is to break
;down the problem into manageable bit. 
;
;Author: <your_name_here>
;
;Changelog:
;1v0 11/24/18 - Base framework to build up for project
;
.include "m8515def.inc" ;comment out for Atmel Studio
;-------------
;passed to termio.inc
.equ FCPU_L  = 1000000 ;used by termio rtn 
.equ BAUD  = 2400    ;desired baud rate

;-------------
;your related equates and dseg requirements
;
.equ MAX   = 40      ;define buffer space limit
   
.dseg
buff:  .byte MAX

.cseg
reset:  rjmp init0

.org  $20
init0:			;first things first, init stack pointer
	ldi R16, low(RAMEND)
	out SPL, R16
	ldi R16, high(RAMEND)
    out SPH, R16
	
	rcall  init_uart  ;you can call this now ADG! ;)
main:
	rcall banner
	rcall getdata    ;sound familiar
	rcall results
fini:  	
    rjmp  main

banner:
	rcall newl	;you don't always need this, but it comes in handy			   ;
	ldi   R30, low(banr<<1)    ;point Z-reg and shoot
	ldi   R31, high(banr<<1)   ;banner message
    rcall puts
	ret
banr: .db "Character Stats 2v4",LF,CR,"By Mr.Markou",LF,CR,NUL

getdata:
	rcall newl
	ldi   R30, low(prmt<<1)   
	ldi   R31, high(prmt<<1)
    rcall puts

	ldi	  R17, MAX        ;leave room for a final CR
	ldi   R30, low(buff)  ;point Z-reg and buffer
	ldi   R31, high(buff)
	rcall gets
	ret
prmt: .db "Enter line>",LF,CR,NUL

;
; Display results of analysis using developed sbrs
results:	
	rcall newl				
	rcall newl				
   	ldi   R30, low(num<<1)
	ldi   R31, high(num<<1)
    rcall puts 

	ldi	  R16, MAX
	sub   R16, R17     ;R17 still has a decremented count from getline()
    rcall hex2bcd8
	rcall hex2asc
	rcall putchar      ;output msd
	mov   R16, R17
	rcall putchar      ;output lsd

    rcall newl
	ret	
num: .db  "Total Numeric characters = ",NUL

;include files must be in the same folder
.include "termio.inc"   ;routines to do terminal io using AVR's USART
.include "numio.inc"    ;routines from same folder
.exit
