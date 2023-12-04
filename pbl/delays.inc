;
; Filename: delays.inc
; Description: Subroutine used for delays in program
;
; Author: nsw
;
; Changelog:
; 2023-12-04: alpha version - delays imported from PBL

dly50usi:
         LDI   R18, 5
         NOP
         NOP
         NOP
         NOP

dly50us:
         NOP
         DEC   R18
         BRNE  dly50us

         CPI   R20, 0  
         BREQ  dlyret
         DEC   R20
         BRNE  dly50usi

dly50msi:
         LDI   R29, $30
         LDI   R28, $03
         NOP
         NOP
         
dly50ms:    
         SBIW  R29:R28, 1
         BRNE  dly50ms
         
         CPI   R20, 0  
         BREQ  dlyret
         DEC   R20
         BRNE  dly50msi

dly2ms:
         LDI   R20, 40
         RJMP  dly50usi

dly500ms:
         LDI   R20, 10
         RJMP  dly50msi

dly1s:
         LDI   R20, 20
         RJMP  dly50msi
         
dlyret:
         RET