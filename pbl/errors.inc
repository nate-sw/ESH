;
; Filename: errors.inc
; Description: Subroutine containing all error codes and scripts relating to errors in program.
;
; Author: nsw
;
; Changelog:
; 2023-12-17: File created






lcd_error_dsp:
lcd_error_dw:
    LDI   R16, $C0
    STS   ADRR1, R16

    LDI   R31, HIGH(errorlcd<<1)
    LDI   R30, LOW(errorlcd<<1)

lcd_error_msg:
    LPM   R16, Z+
    CPI   R16, $00
    BREQ  lcd_error_ret
    RCALL lcd_puts
    RCALL dly10ms
    RJMP  lcd_error_msg

lcd_error_ret:
    RET