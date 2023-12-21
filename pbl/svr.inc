;
; Filename: svr.inc
; Description: Subroutine used for the Supervisor mode
;
; Author: nsw
;
; Changelog:
; 2023-12-19: File created
; 2023-12-20: All systems functional

svr_mode:
svr_msg:
    RCALL  clrs
    LDI   R31, HIGH(svrmsg<<1)
    LDI   R30, LOW(svrmsg<<1)
    RCALL dly50usi
    LDI   R16, $0C	    
    RCALL putchar
    

    RCALL lcd_line_up         
    RCALL msg_dsp
    RCALL helptop
    RCALL svrhelp



stermchk:
    BRID  j_pause_start ;Checks if system time is paused.
    RCALL systime
    IN    R24, PINB
    ANDI  R24, $01
    BRNE  j_svr_ret
    RCALL n_getch_svr
    
    RCALL n_outch
    CPI   R16, $50 ;ascii for 'P'
    BREQ  j_time_pause
    CPI   R16, $52 ;ascii for 'R'
    BREQ  j_reset_menu
    CPI   R16, $54 ;ascii for 'T'
    BREQ  j_term_time
    CPI   R16, $00
    BRNE  j_error_invalid_entry_svr
    RCALL systime
      
    RCALL svr_time
    RJMP  stermchk

j_term_time:
    RJMP   term_time
j_time_pause:
    RJMP   time_pause

j_pause_start:
    RJMP   pause_start

j_svr_ret:
    RJMP   svr_ret

j_reset_menu:
    RJMP   reset_menu

j_error_invalid_entry_svr:
    RJMP  error_invalid_entry_svr

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
    
    LDS   R16, seccnt
    RCALL hex2bcd8
    MOV   R8, R16
    RCALL hex2asc
    MOV   R10, R17
    MOV   R9, R16

    LDI   R16, 'H'
    RCALL lcd_puts
    RCALL dly2ms

    LDI   R16, ':'
    RCALL lcd_puts
    RCALL dly2ms
    MOV   R16, R4
    RCALL lcd_puts
    RCALL dly2ms
    MOV   R16, R5
    RCALL lcd_puts
    RCALL dly2ms
    LDI   R16, $20
    RCALL lcd_puts
    RCALL dly2ms

    LDI   R16, 'M'
    RCALL lcd_puts
    RCALL dly2ms
    LDI   R16, ':'
    RCALL lcd_puts
    RCALL dly2ms
    MOV   R16, R6
    RCALL lcd_puts
    RCALL dly2ms
    MOV   R16, R7
    RCALL lcd_puts
    RCALL dly2ms

    LDI   R16, $20
    RCALL lcd_puts
    RCALL dly2ms

    LDI   R16, 'S'
    RCALL lcd_puts
    RCALL dly2ms
    LDI   R16, ':'
    RCALL lcd_puts
    RCALL dly2ms
    MOV   R16, R8
    RCALL seven_seg_puts
    RCALL dly2ms
    MOV   R16, R9
    RCALL lcd_puts
    RCALL dly2ms
    MOV   R16, R10
    RCALL lcd_puts
    RCALL dly2ms
    RET

svr_ret:
    RET

reset_menu:  
    LDI   R31, HIGH(clkrstwmsg0<<1)
    LDI   R30, LOW(clkrstwmsg0<<1)
    RCALL dly50usi
    RCALL newl
    RCALL newl
    RCALL puts
    LDI   R31, HIGH(clkrstwmsg1<<1)
    LDI   R30, LOW(clkrstwmsg1<<1)
    RCALL dly50usi
    RCALL newl
    RCALL puts
    RCALL cmdinput

reset_chk:
    RCALL systime
    IN    R24, PINB
    ANDI  R24, $01
    BRNE  svr_ret
    RCALL n_getch_svr
    CPI   R16, $43 ;ascii for 'C'
    BREQ  cancel_reset
    CPI   R16, $52 ;ascii for 'R'
    BREQ  time_reset
    RJMP  reset_chk

cancel_reset:
    RCALL n_outch
    CLR   R16
    OUT   UDR, R16
    RJMP  svr_mode

time_reset:
    RCALL n_outch
    CLR   R16
    STS   seccnt, R16
    STS   mincnt, R16
    STS   hrscnt, R16
    LDI   R31, HIGH(clkrstdmsg<<1)
    LDI   R30, LOW(clkrstdmsg<<1)
    RCALL newl
    RCALL newl
    RCALL puts
    RCALL newl
    RJMP  error_ret_msg_svr

time_pause:
    CLI ;Disables interrupt
pause_start:
    RCALL svr_time
    LDI   R31, HIGH(clkpausemsg<<1)
    LDI   R30, LOW(clkpausemsg<<1)
    RCALL newl
    RCALL newl
    RCALL puts
    RCALL cmdinput
pause_chk:
    IN    R24, PINB
    ANDI  R24, $01
    BRNE  jj_svr_ret
    RCALL j_n_getch_svr_p ;Node getch used so the LCD is not being updated constantly.
    
    RCALL n_outch
    CPI   R16, $50 ;ascii for 'P'
    BREQ  unpause
    CPI   R16, $52 ;ascii for 'R'
    BREQ  jj_reset_menu
    CPI   R16, $54 ;ascii for 'T'
    BREQ  term_time
    CPI   R16, $00
    BRNE  error_invalid_entry_svr
    RJMP  pause_chk

unpause:
    SEI ;Enables interrupt
    RJMP  svr_mode

jj_reset_menu:
    CLR   R16
    RJMP  reset_menu
j_n_getch_svr_p:
    RJMP  n_getch_svr_p

jj_svr_ret:
    RJMP   svr_ret


term_time:
    RCALL systime
    RCALL svr_time
    LDI   R31, HIGH(clktermmsg<<1)
    LDI   R30, LOW(clktermmsg<<1)
    RCALL dly50usi
    RCALL newl
    RCALL newl
    RCALL puts
    MOV   R16, R4
    OUT   UDR, R16
    RCALL dly50msi
    MOV   R16, R5
    OUT   UDR, R16
    RCALL dly50msi
    LDI   R16, ':'
    OUT   UDR, R16
    RCALL dly50msi
    MOV   R16, R6
    OUT   UDR, R16
    RCALL dly50msi
    MOV   R16, R7
    OUT   UDR, R16
    RCALL dly50msi
    LDI   R16, ':'
    OUT   UDR, R16
    RCALL dly50msi
    MOV   R16, R9
    OUT   UDR, R16
    RCALL dly50msi
    MOV   R16, R10
    OUT   UDR, R16
    RCALL dly50msi

term_time_fin:
    RCALL newl
    RCALL newl
    RJMP  error_ret_msg_svr

error_invalid_entry_svr:
    
    LDI   R31, HIGH(error0x10<<1)
    LDI   R30, LOW(error0x10<<1)
error_code_print_svr:
    RCALL dly50usi
    RCALL newl
    RCALL newl
    RCALL puts
    RCALL dly50usi
    RCALL lcd_error_dsp

error_ret_msg_svr:
    RCALL newl
    LDI   R31, HIGH(errorret<<1)
    LDI   R30, LOW(errorret<<1)
    RCALL puts
    RCALL dly50usi

svr_error_ret:
    
    RCALL systime
    IN    R24, PINB
    ANDI  R24, $01
    BRNE  jjj_svr_ret
    RCALL n_getch_svr
    CPI   R16, $0D
    BRNE  svr_error_ret
    RJMP  svr_mode

jjj_svr_ret:
    RJMP   svr_ret