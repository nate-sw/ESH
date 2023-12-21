;
; Filename: node.inc
; Description: Subroutine used for the Node mode
;
; Author: nsw
;
; Changelog:
; 2023-12-17: File created
; 2023-12-18: Node function completed, all parts functional

node_mode:
node_msg:
    RCALL systime
    RCALL  clrs
    LDI   R31, HIGH(ndemsg<<1)
    LDI   R30, LOW(ndemsg<<1)
    RCALL dly50usi
    LDI   R16, $0C	    
    RCALL putchar
    

    RCALL lcd_line_up         
    RCALL msg_dsp
    RCALL helptop
    RCALL nodehelp


node_init:
    LDI   R27, HIGH(samples)
    LDI   R26, LOW(samples)
    LDI   R21, $FF ;Number of samples to be taken
    CLR   R22 ;Below trim count
    CLR   R23 ;Above trim count
    LDI   R25, $01 ;junk code



ntermchk:
    RCALL systime
    IN    R24, PINB
    ANDI  R24, $01
    BREQ  j_node_ret
    RCALL n_getch_node
    ;IN    R24, PINB
    ;ANDI  R24, $01
    ;BREQ  j_node_ret
    RCALL n_outch
    CPI   R16, $41 ;ascii for 'A'
    BREQ  node
    CPI   R16, $54 ;ascii for 'T'
    BREQ  j_change_trim
    CPI   R16, $53 ;ascii for 'S'
    BREQ  j_no_sample
    CPI   R16, $00
    BRNE  j_node_invalid_entry
    BRID  ntermchk
    RCALL systime
    RJMP  ntermchk

j_node_ret:
    RJMP  node_ret


j_change_trim:
    RJMP change_trim

j_no_sample:
    RCALL lcd_error_dsp
    RJMP error_no_sample

j_node_invalid_entry:
    RCALL lcd_error_dsp
    RJMP  error_invalid_entry


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

    LDS   R3, trimlvl
    CP    R24, R3 
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
    RCALL newl
    LDI   R31, HIGH(ndefmsg<<1)
    LDI   R30, LOW(ndefmsg<<1)
    RCALL dly50usi  
    RCALL puts
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
    RCALL newl
    

node_end_msg:
    LDI   R31, HIGH(samplesummsg<<1)
    LDI   R30, LOW(samplesummsg<<1)
    RCALL dly50usi
    RCALL newl

    RCALL puts

    RCALL newl
    LDI   R31, HIGH(errorret<<1)
    LDI   R30, LOW(errorret<<1)
    RCALL puts
    RCALL dly50usi

node_end_chk:
    
    IN    R24, PINB
    ANDI  R24, $01
    BREQ  node_ret
    RCALL n_getch_node
    IN    R24, PINB
    ANDI  R24, $01
    BREQ  node_ret
    RCALL n_outch
    CPI   R16, $53 ;ascii for 'S'
    BREQ  j_sum
    CPI   R16, $0D ;ascii CR
    BREQ  j_node_msg
    CPI   R16, $54 ;ascii for 'T'
    BREQ  j_error_invalid_trim
    CPI   R16, $00
    BRNE  jj_node_invalid_entry
    BRID  node_end_chk
    RCALL systime
    RJMP  node_end_chk




j_error_invalid_trim:
    RCALL lcd_error_dsp
    RJMP  error_invalid_trim

j_node_msg:
    RJMP  node_msg

j_sum:
    RJMP startsum

jj_node_invalid_entry:
    RCALL lcd_error_dsp
    RJMP  error_invalid_entry

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
    OUT   UDR, R17
    RCALL dly50msi


enter_new_trim:
    LDI   R31, HIGH(trimmesg1<<1)
    LDI   R30, LOW(trimmesg1<<1)
    LDI   R18, 2
    RCALL dly50usi
    RCALL newl

    RCALL puts

getch_trim:
    RCALL systime
    IN    R24, PINB
    ANDI  R24, $01
    BREQ  node_ret
    RCALL dly2ms
    RCALL n_getch_node
    RCALL dly2ms
    
    CPI   R16, $00
    BREQ  getch_trim
    CPI   R16, $30
    BRLO  j_invalid_hex
    CPI   R16, $3A
    BRSH  chk_new_trim
    
    CPI   R16, $0D
    BREQ  j_invalid_hex
    OUT   UDR, R16
    
    SUBI  R16, $30
    RJMP  save_trim


chk_new_trim:
    CPI   R16, $41
    BRLO  j_invalid_hex
    CPI   R16, $47
    BRSH  j_invalid_hex
    OUT   UDR, R16
    SUBI  R16, $37
    RJMP  save_trim

    j_invalid_hex:
    OUT   UDR, R16
    RCALL lcd_error_dsp
    RJMP  error_invalid_hex
    

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
    RCALL n_getch_node
    CPI   R16, $0D
    BRNE  trim_ret
    RJMP  node_msg

trim_msv:
    MOV R4, R16
    LSL   R4
    LSL   R4
    LSL   R4
    LSL   R4

    RJMP  getch_trim

startsum:
    RCALL systime
    PUSH  R16
    IN    R16, SREG
    PUSH  R16
    PUSH  R17
    PUSH  R18
    CLR   R17
    CLR   R18
    CLR   R27
    CLR   R28
    LDI   R17, $0F
    LDI   R18, $F0
    LDI   R27, HIGH(samples)
    LDI   R26, LOW(samples)
    LDI   R21, $FF ;Number of samples to be taken
    CLR   R0
    CLR   R1
    CLR   R2
    CLR   R3

sumloop:
    RCALL systime
    LD    R0, x+
    ADD   R2, R0
    ADC   R3, R1
    DEC   R21
    BRNE  sumloop

sumdone:  
    LDI   R31, HIGH(ndesmsg<<1)
    LDI   R30, LOW(ndesmsg<<1)
    RCALL dly50usi
    RCALL newl
    RCALL newl

    RCALL puts

    MOV   R16, R3 ;converts sum to ascii
    RCALL hex2asc
    MOV   R5, R17
    MOV   R4, R16
    MOV   R16, R2
    RCALL hex2asc
    MOV   R7, R17
    MOV   R6, R16

    MOV   R16, R4
    OUT   UDR, R16
    RCALL dly50msi
    MOV   R16, R5
    OUT   UDR, R16
    RCALL dly50msi
    MOV   R16, R6
    OUT   UDR, R16
    RCALL dly50msi
    MOV   R16, R7
    OUT   UDR, R16
    RCALL dly50msi

    POP   R18
    POP   R17
    POP   R16
    OUT   SREG, R16
    POP   R16

    CLR   R27
    CLR   R26
    RCALL newl
    RJMP  error_ret_msg_node



error_invalid_hex:  
    LDI   R31, HIGH(error0x21<<1)
    LDI   R30, LOW(error0x21<<1)
    RJMP  error_code_print_node

error_invalid_entry:
    LDI   R31, HIGH(error0x20<<1)
    LDI   R30, LOW(error0x20<<1)
    RJMP  error_code_print_node

error_no_sample:
    LDI   R31, HIGH(error0x22<<1)
    LDI   R30, LOW(error0x22<<1)
    RJMP  error_code_print_node

error_invalid_trim:
    LDI   R31, HIGH(error0x23<<1)
    LDI   R30, LOW(error0x23<<1)

error_code_print_node:
    RCALL dly50usi
    RCALL newl
    RCALL newl
    RCALL puts
    RCALL dly50usi

error_ret_msg_node:
    RCALL newl
    LDI   R31, HIGH(errorret<<1)
    LDI   R30, LOW(errorret<<1)
    RCALL puts
    RCALL dly50usi

node_error_ret:
    RCALL systime
    IN    R24, PINB
    ANDI  R24, $01
    BREQ  jj_node_ret
    RCALL n_getch_node
    CPI   R16, $0D
    BRNE  node_error_ret
    RJMP  node_msg

jj_node_ret:
    RJMP  node_ret