;
; Filename: lcdio.inc
; Description: Subroutine containing the LCD initialization and IO code.
;
; Author: nsw
;
; Changelog:
; 2023-12-04: alpha version - code imported from PBL




lcd_clr:
    LDI   R16, $01 ;clear display
    RJMP  lcdio_ret

lcd_line_up:
    LDI   R16, $80
    RJMP  lcdio_ret

lcd_line_dw:
    LDI   R16, $C0
    RJMP  lcdio_ret



lcd_puts:
    STS   ADRR2, R16
    RET


lcdio_ret:
    STS   ADRR1, R16
    RET


lcd_msg_dsp:
    LPM   R16, Z+
    CPI   R16, $00
    BREQ  lcd_msg_ret
    RCALL lcd_puts
    RCALL dly10ms
    RCALL dly50msi
    RJMP  msg_dsp

lcd_msg_ret:
    RET