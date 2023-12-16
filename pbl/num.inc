;
; Filename: num.inc
; Description: Subroutine to convert decimal values into ascii
;
; Author: nsw
;
; Changelog:
; 2023-12-07: created file
; 2023-12-16:
; -Created h2asc, based off a modified version of hex2asc by Mr. Markou


h2asc:
     clr   R17
     mov   R15,R16      ;make copy of hex number


     
     lsr   R16          ;shift ms nyble to ls
     lsr   R16     
     lsr   R16
     lsr   R16
     
h2asc_a:
     andi  R16,$0F     ;mask off upper nyble
     cpi   R16,$0A     
     brlo  h2asc_b
     SUBI  R16, 8
     



     ldi   R18,$30   
     add   R16,R18     ;add $30 to adjust to ascii 0 - 9
     
     ldi   R18,7       ;adjust to hex char into 'A' - 'F'
     add   R16,R18



h2asc_b:
     push  R16		   ;save lsd ascii
     mov   R16,R15
     inc   R17
     cpi   R17,1
     breq  h2asc_a
	 pop  R17           ;R17:R16 contain msd:lsd ascii numbers
     pop  R16
     ret
