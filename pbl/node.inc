;
; Filename: node.inc
; Description: Subroutine used for the Node mode
;
; Author: nsw
;
; Changelog:
; 2023-12-17: File created

error_invalid_entry:
    LDI   R31, HIGH(error0x20<<1)
    LDI   R30, LOW(error0x20<<1)
    RJMP  error_code_print



error_code_print:
    RCALL dly50usi
    RCALL newl
    RCALL newl

    RCALL puts
    RCALL dly50usi
    RCALL newl

error_ret_msg:
    LDI   R31, HIGH(errorret<<1)
    LDI   R30, LOW(errorret<<1)
    RCALL puts
    RCALL dly50usi
error_ret:
    RCALL n_getch
    CPI   R16, $0D
    BRNE  error_ret


node_msg:
    LDI   R31, HIGH(ndemsg<<1)
    LDI   R30, LOW(ndemsg<<1)
    RCALL dly50usi
    LDI   R16, $0C	    
    RCALL putchar

    RCALL lcd_line_up         
    RCALL msg_dsp


node_init:
    LDI   R27, HIGH(samples)
    LDI   R26, LOW(samples)
    LDI   R21, $FE ;Number of samples to be taken
    CLR   R22 ;Below trim count
    CLR   R23 ;Above trim count
    LDI   R25, $01 ;junk code



ntermchk:
    RCALL n_getch
    RCALL n_outch
    CPI   R16, $41
    BREQ  node
    CPI   R16, $54
    BREQ  j_change_trim
    CPI   R16, $00
    BRNE  error_invalid_entry
    RJMP  ntermchk

j_change_trim:
    RJMP change_trim

node:
    STS   ADCADR, R25

adcping:
    IN    R24, PINB
    ANDI  R24, $04
    BREQ  adcping

nodecont:
    LDS   R24, $1000
    ST    x+, R24
    LDI   R16, 1
    OUT   PORTE, R16
    NOP
    NOP
    NOP
    CLR   R16
    OUT   PORTE, R16


    CPI   R24, $80 ;Default trim value - Change later to add logic
    BRLO  ltrim
    
    RCALL dly2ms

    ;RCALL dly200ms ;Used for debugging


    INC   R23
    DEC   R21
    BRNE  node 
    RJMP  node_fini

ltrim: ;lower than trim level
    RCALL dly2ms
    INC   R22
    DEC   R21
    BRNE  node 
    RJMP  node_fini

node_fini:
    RCALL lcd_line_dw
    RCALL newl

    MOV   R16, R22
    RCALL hex2asc
    MOV   R5, R17
    MOV   R4, R16

    MOV   R16, R23
    RCALL hex2asc
    MOV   R7, R17
    MOV   R6, R16
    
    LDI   R16, 'L'
    RCALL lcd_puts
    OUT   UDR, R16
    RCALL dly50msi
    LDI   R16, ':'
    RCALL lcd_puts
    OUT   UDR, R16
    RCALL dly50msi
    MOV   R16, R4
    RCALL lcd_puts
    OUT   UDR, R16
    RCALL dly50msi
    MOV   R16, R5
    RCALL lcd_puts
    OUT   UDR, R16
    RCALL dly50msi
    LDI   R16, $20
    RCALL lcd_puts
    OUT   UDR, R16
    RCALL dly50msi
    LDI   R16, 'H'
    RCALL lcd_puts
    OUT   UDR, R16
    RCALL dly50msi
    LDI   R16, ':'
    RCALL lcd_puts
    OUT   UDR, R16
    RCALL dly50msi
    MOV   R16, R6
    RCALL lcd_puts
    OUT   UDR, R16
    RCALL dly50msi
    MOV   R16, R7
    RCALL lcd_puts
    OUT   UDR, R16
    RCALL dly50msi

    RJMP  node_init
node_ret:
    RET



change_trim:
    LDI   R31, HIGH(trimmesg0<<1)
    LDI   R30, LOW(trimmesg0<<1)
    RCALL dly50usi
    RCALL newl

    RCALL puts

    LDS   R16, trimlvl
    RCALL hex2asc

    OUT   UDR, R16
    RCALL dly50msi
    MOV   R16, R17
    OUT   UDR, R16
    RCALL dly50msi


enter_new_trim:
    LDI   R31, HIGH(trimmesg1<<1)
    LDI   R30, LOW(trimmesg1<<1)
    LDI   R18, 2
    RCALL dly50usi
    RCALL newl

    RCALL puts

getch_trim:
    RCALL dly2ms
    RCALL n_getch
    RCALL dly2ms
    
    CPI   R16, $30
    
    BRLO  error_invalid_hex
    CPI   R16, $3A
    BRSH  chk_new_trim
    CPI   R16, $00
    BREQ  getch_trim
    CPI   R16, $0D
    BREQ  error_invalid_hex
    OUT   UDR, R16
    
    SUBI  R16, $30
    RJMP  save_trim


chk_new_trim:
    CPI   R16, $41
    BRLO  error_invalid_hex
    CPI   R16, $47
    BRSH  chk_new_trim
    OUT   UDR, R16
    SUBI  R16, $37
    

save_trim:
    DEC   R18
    BRNE  trim_msv
    ADD   R16, R4
    STS   trimlvl, R16

trim_set:
    RCALL newl
    LDI   R31, HIGH(trimset<<1)
    LDI   R30, LOW(trimset<<1)
    RCALL dly50usi
    RCALL newl

    RCALL puts
trim_ret:
    RCALL n_getch
    CPI   R16, $0D
    BRNE  trim_ret
    RJMP  node_msg

trim_msv:
    MOV R4, R16
    LSL R4
    LSL R4
    LSL R4
    LSL R4

    RJMP  getch_trim



error_invalid_hex:  ;Note 2023-12-17 - This doesn't seem to work, try to make a .inc for the errors are restructure the code.
    LDI   R31, HIGH(error0x21<<1)
    LDI   R30, LOW(error0x21<<1)
    RJMP  error_code_print



