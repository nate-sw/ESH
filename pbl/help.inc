;
; Filename: help.inc
; Description: Subroutines which display the valid commands for both node and supervisor modes.
;
; Author: nsw
;
; Changelog:
; 2023-12-20: File created

helptop:
    RCALL dly2ms
    LDI   R31, HIGH(helptopmsg<<1)
    LDI   R30, LOW(helptopmsg<<1)
    RCALL dly50usi
    RCALL newl
    RCALL newl
    RCALL puts
    RET

svrhelp:
    RCALL newl
    RCALL newl
    LDI   R31, HIGH(svrhelp0<<1)
    LDI   R30, LOW(svrhelp0<<1)
    RCALL dly50usi
    RCALL puts
    RCALL newl
    LDI   R31, HIGH(svrhelp1<<1)
    LDI   R30, LOW(svrhelp1<<1)
    RCALL dly50usi
    RCALL puts
    RCALL newl
    LDI   R31, HIGH(svrhelp2<<1)
    LDI   R30, LOW(svrhelp2<<1)
    RCALL dly50usi
    RCALL puts
    RJMP  cmdinput


nodehelp:
    RCALL newl
    RCALL newl
    LDI   R31, HIGH(nodehelp0<<1)
    LDI   R30, LOW(nodehelp0<<1)
    RCALL dly50usi
    RCALL puts
    RCALL newl
    LDI   R31, HIGH(nodehelp1<<1)
    LDI   R30, LOW(nodehelp1<<1)
    RCALL dly50usi
    RCALL puts
    RCALL newl
    LDI   R31, HIGH(nodehelp2<<1)
    LDI   R30, LOW(nodehelp2<<1)
    RCALL dly50usi
    RCALL puts
    RJMP  cmdinput

cmdinput:
    LDI   R31, HIGH(cmdipt<<1)
    LDI   R30, LOW(cmdipt<<1)
    RCALL dly50usi
    RCALL newl
    RCALL newl
    RCALL puts
    RET