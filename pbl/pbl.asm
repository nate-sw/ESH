;
; PBL
; 2023-11-27
; Author : nsw
;

.include "m8515def.inc"
;
; Refer to doc2512.pdf
; Changelog:
;
; 2023-12-11:  Reworked program startup and LCD display code.
; 2023-12-18:  Node mode completed.
; 2023-12-20:  Supervisor mode completed.


.dseg

seccnt:  .byte 1
mincnt:  .byte 1
hrscnt:  .byte 1


tickcnt: .byte 1


trimlvl: .byte 1

samples: .byte 1



.cseg
reset: RJMP init0
int_0: RJMP  isr0
.org $20

.equ     BUSON = $82
.equ     ADCADR = $1000 ; Memory address for ADC
.equ     SVSEGADR = $1800 ; Memory address for 7 segment displays
.equ     ADRR1 = $2000 ; Memory address for LCD's control
.equ     ADRR2 = $2100 ; Memory address for LCD's data

;passed to termio.inc
.equ FCPU_L  = 1000000 ;used by termio rtn 
.equ BAUD  = 2400    ;desired baud rate

init0:
    CLR   R16
    STS   tickcnt, R16
    STS   seccnt, R16
    STS   mincnt, R16
    STS   hrscnt, R16

    ; Enable External Interrupt 0
    ldi   R16, $40
    out   GICR, R16


    LDI   R16, LOW(RAMEND) ;Initialize stack pointer.
    OUT   SPL, R16
    LDI   R16, HIGH(RAMEND)
    OUT   SPH, R16
    
    LDI   R16, $FA 
    OUT   DDRB, R16 ;config PB0 & PB2 as input
    LDI   R16, $02 
    OUT   DDRE, R16 ;config PE0 as output


    RCALL j_init_uart

init_bus:
    LDI   R16, BUSON
    OUT   MCUCR, R16
    
init_trim:
    LDI R16, $80 ;Default trim level
    STS trimlvl, R16

         
init1:
    RCALL pgm_start
    LDI   R21, 3
    RCALL newl

foursec_wait:
    RJMP  n_getch_start

j_cookiejar:
    RJMP cookiejar

init2:
    SEI ;Enables interrupt

main:
    RCALL  systime
    IN    R24, PINB
    ANDI  R24, $01
    BRNE  c_node
    RJMP  c_svr

c_svr:
    RCALL svr_mode
    RJMP main

c_node:
    RCALL node_mode 
    RJMP  main

msg_dsp:
    LPM   R16, Z+
    CPI   R16, $00
    BREQ  msg_ret
    RCALL lcd_puts
    RCALL putchar
    
    
    RCALL dly10ms
    RCALL dly50msi
    RJMP  msg_dsp

msg_ret:
    RET

; insert lcd_puts here for debuging

; insert delays here for debuging

clrs:
    RCALL lcd_clr
    RCALL dly2ms
    RET

fini:
    RJMP  fini

j_getche:
    RJMP  getche

j_init_uart:
    RJMP  init_uart

j_hex2asc:
    RJMP  hex2asc



systime:
    PUSH  R16
    BRID  systime_ret

secchk:
    LDS   R16, seccnt
    CPI   R16, 60
    BRSH  minutesinc
    STS   seccnt, R16
    RJMP  systime_ret

minutesinc:
    CLR   R16
    STS   seccnt, R16
    LDS   R16, mincnt
    INC   R16
    CPI   R16, 60
    BREQ  hoursinc
    STS   mincnt, R16
    RJMP  systime_ret

hoursinc:
    CLR   R16
    STS   mincnt, R16
    LDS   R16, hrscnt
    INC   R16
    CPI   R16, 99
    BREQ  hoursinc
    STS   hrscnt, R16
    RJMP  systime_ret

hours_clr:
    CLR   R16
    STS   hrscnt, R16
    RJMP  systime_ret

systime_ret:
    POP   R16
    RET


isr0: ;This is the interrupt for the system clock
    PUSH  R16
    IN    R16, SREG
    PUSH  R16
    LDS   R16, tickcnt
    INC   R16
    CPI   R16, 63 ;Changed to 63 due to the 556's frequency of 63Hz
    BRSH  sec_int0
    STS   tickcnt, R16
    POP   R16
    OUT   SREG, R16
    POP   R16
    RETI


sec_int0:
    CLR   R16
    STS   tickcnt, R16
    LDS   R16, seccnt
    INC   R16
    STS   seccnt, R16
    POP   R16
    OUT   SREG, R16
    POP   R16
    RETI






msg0:    .db   $0D, "DatAQMon_v1.0", $00
msg1:    .db   "2032574 ",  $00
svrmsg:  .db   $0D, "SUPERVISOR#", $00
clkrstwmsg0: .db   $0D, "Warning: The system uptime should only be reset manually in the event of maintenance work.", $00
clkrstwmsg1: .db   $0D, "Please press 'R' to reset the uptime clock or 'C' to return to the previous menu. ", $00
clkrstdmsg: .db   $0D, "System uptime reset.", $00
clkpausemsg: .db   $0D, "System uptime is paused. Press 'P' to unpause. ", $00
clktermmsg: .db   $0D, "System uptime: ", $00

ndemsg:  .db   $0D, "NODE>", $00
ndefmsg: .db   $0D, "New sample set captured:", $00
samplesummsg: .db   $0D, "To view the sum of the captured samples, press 'S'", $00
ndesmsg: .db   $0D, "Sum of collected samples [XXXX]: ", $00
trimmesg0:.db   $0D, "Current trim level is [XX]: ", $00
trimmesg1:.db   $0D, "Set new trim level [XX]: ", $00
trimset: .db   $0D, "New Trim level set. Press Enter to return to previous menu", $00



error0x10:.db   $0D, "[Error 0x10] - Invalid entry. Please insert a valid Supervisor command", $00



error0x20:.db   $0D, "[Error 0x20] - Invalid entry. Please insert a valid Node command.", $00
error0x21:.db   $0D, "[Error 0x21] - Invalid value. Please insert a hex value between 0x00 and 0xFF.", $00
error0x22:.db   $0D, "[Error 0x22] - Missing sample. Please take a sample before using the sum command.", $00
error0x23:.db   $0D, "[Error 0x23] - Invalid trim cmd. Please reload the page before inputting a new trim level.", $00

errorlcd:.db   " ERROR CHECK TERM", $00

errorret: .db   $0D, "Press Enter to return to the previous menu. ", $00

helptopmsg:  .db   $0D, "Command list - Must be uppercase.", $00
svrhelp0: .db   $0D, "R - Reset system uptime clock.", $00
svrhelp1: .db   $0D, "P - Pause system uptime clock at it's current point.", $00
svrhelp2: .db   $0D, "T - Display the current uptime in the terminal.", $00
nodehelp0:.db   $0D, "A - Acquire a new sample set.", $00
nodehelp1:.db   $0D, "S - Display the sum of the sample set. Requires a sample set.", $00
nodehelp2:.db   $0D, "T - Set a new trim level. Must be set before a sample is taken.", $00
cmdipt:   .db   $0D, ">", $00

cookie0:   .db   $0D, "Of our elaborate plans, the end", $00
cookie1:   .db   $0D, "Of everything that stands, the end", $00
cookie2:   .db   $0D, "No safety or surprise, the end", $00
cookie3:   .db   $0D, "I'll never look into your eyes again", $00





.include "delays.inc"
.include "lcdio.inc"
.include "startup.inc"
.include "node.inc"
.include "termcmd.inc"
.include "errors.inc"
.include "svr.inc"
.include "help.inc"

.include "termio.inc"   ;routines to do terminal io using AVR's USART
.include "numio.inc" 
.exit