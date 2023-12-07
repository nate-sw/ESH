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


lcd_init:
fctn_set:               
         LDI   R16, $38 ;function set
         RJMP  lcdio_ret

lcd_on:
         LDI   R16, $0C ;Turn display on, cursor and position on
         RJMP  lcdio_ret

lcd_clr:
         LDI   R16, $01 ;clear display
         RJMP  lcdio_ret

lcd_ent_md:
         LDI   R16, $06 ;entry mode
         RJMP  lcdio_ret


lcd_line_up:
         LDI   R16, $80
         RJMP  lcdio_ret

lcd_line_dw:
         LDI   R16, $C0
         RJMP  lcdio_ret



lcd_puts:
         STS   ADRR2, R17
         RET


lcdio_ret:
         STS   ADRR1, R16
         RET