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


.dseg
trimlvl:.byte 1

samples:.byte 1

tickcnt:.byte 1
sec:    .byte 1
min:    .byte 1
hrs:    .byte 1

.cseg
;RJMP init0
;RJMP  isr0


.equ     BUSON = $80
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
    STS   sec, R16
    STS   min, R16
    STS   hrs, R16

    ; Enable External Interrupt 0
    ldi   R16, (1<<INT0)
    out   GICR, R16

    ; Set interrupt trigger on falling edge
    LDI   R16, (1<<ISC01)
    OUT   MCUCR, R16


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
    SEI ;Enables interrupt

main:    
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

clr:
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


isr0: ;This is the interrupt for the system clock
    PUSH  R16
    LDS   R16, tickcnt
    INC   R16
    CPI   R16, 60
    BREQ  secondsinc
    STS   tickcnt, R16

done_isr0:
    POP   R16
    RETI


secondsinc:
    CLR   R16
    STS   tickcnt, R16
    LDS   R16, tickcnt
    INC   R16
    CPI   R16, 60
    BREQ  minutesinc
    STS   min, R16
    RJMP  done_isr0

minutesinc:
    CLR   R16
    STS   sec, R16
    LDS   R16, min
    INC   R16
    CPI   R16, 60
    BREQ  hoursinc
    STS   min, R16
    RJMP  done_isr0

hoursinc:
    CLR   R16
    STS   min, R16
    LDS   R16, hrs
    INC   R16
    CPI   R16, 99
    BREQ  hoursinc
    STS   hrs, R16
    RJMP  done_isr0

hours_clr:
    CLR   R16
    STS   hrs, R16
    RJMP  done_isr0



msg0:    .db   $0D, "DatAQMon_v1.0", $00
msg1:    .db   "2032574",  $00


svrmsg:  .db   $0D, "SUPERVISOR#", $00

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

errorlcd:.db   $0D, "ERROR CHECK TRM", $00

errorret: .db   $0D, "Press Enter to return to the previous menu. ", $00



.include "delays.inc"
.include "lcdio.inc"
.include "startup.inc"
.include "node.inc"
.include "termcmd.inc"
.include "errors.inc"
.include "svr.inc"

.include "termio.inc"   ;routines to do terminal io using AVR's USART
.include "numio.inc" 
.exit