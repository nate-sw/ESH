;
; Lab 4 prelab
; 2023-09-25
; Author : nsw
;

.include "m8515def.inc"


.cseg

init:
         LDI   R16, $FF
         OUT   DDRA, R16 ;config PORTA's 4 LSBs as outputs
         LDI   R16, $00
         OUT   DDRD, R16 ;config PORTD's 4 LSBs as inputs

loop:
         IN    R16, PIND
         OUT   PORTA, R16 

         RJMP  loop ;repeat above inst's