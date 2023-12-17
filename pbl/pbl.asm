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


.dseg
min:	.byte 1
tenmin:	.byte 1
hrs:	.byte 1
tenhrs:	.byte 1

samples:.byte 1

trimlvl:.byte 1

.cseg

.equ     BUSON = $80
.equ     ADCADR = $1000 ; Memory address for ADC
.equ     SVSEGADR = $1800 ; Memory address for 7 segment displays
.equ     ADRR1 = $2000 ; Memory address for LCD's control
.equ     ADRR2 = $2100 ; Memory address for LCD's data

.equ     SecondsAddr = 0x1850 ; Memory address for seconds
.equ     MinutesAddr = 0x2150 ; Memory address for minutes
.equ     HoursAddr   = 0x2151 ; Memory address for hours




;passed to termio.inc
.equ FCPU_L  = 1000000 ;used by termio rtn 
.equ BAUD  = 2400    ;desired baud rate





init0:
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

         
         


main:    
    RCALL pgm_start

    RCALL  clr ;Use only for troubleshooting startup message

    RCALL  node_msg




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





msg0:    .db   $0D, "DatAQMon_v1.0", $00
msg1:    .db   "2032574",  $00


svrmsg:  .db   $0D, "SUPERVISOR# ", $00
ndemsg:  .db   $0D, "NODE>", $00

trimmesg0:.db   $0D, "Current trim level is [XX]: ", $00
trimmesg1:.db   $0D, "Set new trim level [XX] and hit Enter key: ", $00


error0x10:.db   $0D, "[Error 0x10] - Invalid entry. Please insert a valid Supervisor command", $00



error0x20:.db   $0D, "[Error 0x20] - Invalid entry. Please insert a valid Node command.", $00
error0x21:.db   $0D, "[Error 0x21] - Invalid value. Please insert a hex value between 0x00 and 0xFF.", $00

errorlcd:.db   $0D, "ERROR - CHECK TERM", $00

errorret: .db   $0D, "Press Enter to return to the previous menu.", $00

.include "delays.inc"
.include "lcdio.inc"
.include "startup.inc"
.include "num.inc" 
.include "node.inc"
.include "termcmd.inc"
.include "errors.inc"

.include "termio.inc"   ;routines to do terminal io using AVR's USART
.include "numio.inc" 
.exit