;
; Filename: lcdstartup.inc
; Description: Contains all code pertaining to the pgm startup
;
; Author: nsw
;
; Changelog:
; 2023-12-15: File created

pgm_start:
        RCALL dly50msi
;fctn_set:               
        LDI   R16, $38 ;function set
        STS   ADRR1, R16
        RCALL dly50usi
        LDI   R16, $38 ;function set
        STS   ADRR1, R16
        RCALL dly50usi
;lcd_on:
        LDI   R16, $0C ;Turn display on, cursor and position on
        STS   ADRR1, R16
        RCALL dly50usi
; clear lcd
        RCALL lcd_clr
        RCALL dly2ms
;lcd_ent_md:
        LDI   R16, $06 ;entry mode
        STS   ADRR1, R16
        RCALL dly50usi

;init_msg0:
        LDI   R31, HIGH(msg0<<1)
        LDI   R30, LOW(msg0<<1)
        RCALL dly2ms
        CLR   R16

;startup:
        LDI   R16, $0C	    
        RCALL putchar
        CLR   R16
        RCALL lcd_line_up
        RCALL msg_dsp
        RCALL newl
        CLR   R16
        RCALL lcd_line_dw
        LDI   R31, HIGH(msg1<<1)
        LDI   R30, LOW(msg1<<1)
        RCALL dly50usi
        RCALL msg_dsp
        RCALL dly4s


        RET

n_getch_start:
    DEC   R21
    BREQ  j_init2
    RCALL dly1s
    IN    R16, UCSRA
    ANDI  R16, $80
    BREQ  n_getch_start
    IN    R16, UDR
    CPI   R16, $45 ;ascii for 'E'
    BREQ  cookiejar
    RJMP  n_getch_start

j_init2:
    RJMP  init2

cookiejar:
    LDI   R16, $0C	    
    RCALL putchar
    RCALL n_outch
    LDI   R31, HIGH(cookie0<<1)
    LDI   R30, LOW(cookie0<<1)
    RCALL dly50usi
    RCALL puts
    LDI   R31, HIGH(cookie1<<1)
    LDI   R30, LOW(cookie1<<1)
    RCALL dly50usi
    RCALL newl
    RCALL puts
    LDI   R31, HIGH(cookie2<<1)
    LDI   R30, LOW(cookie2<<1)
    RCALL dly50usi
    RCALL newl
    RCALL puts
    LDI   R31, HIGH(cookie3<<1)
    LDI   R30, LOW(cookie3<<1)
    RCALL dly50usi
    RCALL newl
    RCALL puts

    RCALL newl
    RCALL newl
    LDI   R31, HIGH(errorret<<1)
    LDI   R30, LOW(errorret<<1)
    RCALL puts
    RCALL dly50usi

cookie_ret:
    RCALL n_getch_start
    CPI   R16, $0D
    BRNE  cookie_ret
    RJMP  init0