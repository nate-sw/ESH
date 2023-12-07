;
; Filename: dec2ascii.inc
; Description: Subroutine to convert decimal values into ascii
;
; Author: nsw
;
; Changelog:
; 2023-12-07: created file

;R20 is used for minutes, R21 is used for hours


min:  
         LDI  R16, $30
         MOV  R26, R20
         ADD  R26, R16 ;converts the LSD to ascii by adding $30
         LDI  R27, $30 ;converts the LSD to ascii value 0