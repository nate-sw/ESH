;
; Filename: lcdio.inc
; Description: Subroutine containing the LCD initialization and IO code.
;
; Author: nsw
;
; Changelog:
; 2023-12-04: alpha version - code imported from PBL
.equ     ADRR1 = $2000
.equ     ADRR2 = $2100

fctn_set:               ;function set
         LDI   R16, $38 
         RJMP  con_ret

lcd_on:
         LDI   R16, $0F ;Turn display on, cursor and position on
         RJMP  con_ret

lcd_clr:
         LDI   R16, $01 ;clear display
         RJMP  con_ret

ent_md:
         LDI   R16, $06 ;entry mode
         RJMP  con_ret




lcd_puts:
         STS   ADRR2, R17
         RET


con_ret:
         STS   ADRR1, R16
         RET