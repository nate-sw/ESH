;
; Filename: svr.inc
; Description: Subroutine used for the Supervisor mode
;
; Author: nsw
;
; Changelog:
; 2023-12-19: File created

svr_mode:

svr_msg:
    RCALL systime
    RCALL  clrs
    LDI   R31, HIGH(svrmsg<<1)
    LDI   R30, LOW(svrmsg<<1)
    RCALL dly50usi
    LDI   R16, $0C	    
    RCALL putchar

    RCALL lcd_line_up         
    RCALL msg_dsp

    RCALL systime


stermchk:
    RCALL systime
    IN    R24, PINB
    ANDI  R24, $01
    BRNE  j_svr_ret
    ;RCALL n_getch
    ;IN    R24, PINB
   ; ANDI  R24, $01
    ;BREQ  j_node_ret
    ;RCALL n_outch
    ;CPI   R16, $41 ;ascii for 'A'
    ;BREQ  node
    ;CPI   R16, $54 ;ascii for 'T'
    ;BREQ  j_change_trim
    ;CPI   R16, $53 ;ascii for 'S'
    ;BREQ  j_no_sample
    ;CPI   R16, $00
    ;BRNE  j_invalid_entry
    RCALL  systime
    RJMP   svr_time

    j_svr_ret:
    RJMP   svr_ret


svr_time:
    RCALL lcd_line_dw


    LDS   R16, hrscnt
    RCALL hex2bcd8
    RCALL hex2asc
    MOV   R5, R17
    MOV   R4, R16

    LDS   R16, mincnt
    RCALL hex2bcd8
    RCALL hex2asc
    MOV   R7, R17
    MOV   R6, R16
    
    ;LDS   R16, seccnt
    ;RCALL hex2bcd8
    ;MOV   R8, R16
    ;RCALL hex2asc
    ;MOV   R10, R17
    ;MOV   R9, R16

    LDI   R16, 'H'
    RCALL lcd_puts
    RCALL dly10ms

    LDI   R16, ':'
    RCALL lcd_puts
    RCALL dly10ms
    MOV   R16, R4
    RCALL lcd_puts
    RCALL dly10ms
    MOV   R16, R5
    RCALL lcd_puts
    RCALL dly10ms
    LDI   R16, $20
    RCALL lcd_puts
    RCALL dly10ms

    LDI   R16, 'M'
    RCALL lcd_puts
    RCALL dly10ms
    LDI   R16, ':'
    RCALL lcd_puts
    RCALL dly10ms
    MOV   R16, R6
    RCALL lcd_puts
    RCALL dly10ms
    MOV   R16, R7
    RCALL lcd_puts
    RCALL dly10ms

    LDI   R16, $20
    RCALL lcd_puts
    RCALL dly10ms

    LDI   R16, 'S'
    RCALL lcd_puts
    RCALL dly10ms
    LDI   R16, ':'
    RCALL lcd_puts
    MOV   R16, R8
    RCALL seven_seg_puts
    MOV   R16, R9
    RCALL lcd_puts
    RCALL dly10ms
    MOV   R16, R10
    RCALL lcd_puts
    RCALL dly10ms

    ;RCALL dly1s ;Only for troubleshooting, remove later
    RJMP  stermchk



svr_ret:
    RET