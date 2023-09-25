;
; Lab 4 Task 2
; 2023-09-25
; Author : nsw
;

.include "m8515def.inc"

.equ     LIM1= ;500Hz
.equ     LIM2=
.equ     LIM3=
.equ     LIM4=

init:
         LDI   R16, $FF ;1 cycle
         OUT   DDRA, R16 ;config PORTA as all outputs - 1 cycle
         LDI   R16, $00
         OUT   DDRD, R16
chkin:
         IN    R18, PIND

         CPI   R18, 1
         BREQ dlyinit1
         CPI   R18, 2
         BREQ dlyinit2
         CPI   R18, 4
         BREQ dlyinit3
         CPI   R18, 8
         BREQ dlyinit4

dlyinit1:
         LDI   R20, LIM1
dlyinit2:
         LDI   R20, LIM2
dlyinit3:
         LDI   R20, LIM3
dlyinit4:
         LDI   R20, LIM4
init1:
         LDI   R16, 0 ;1 cycle
         LDI   R17, 1 ;1 cycle
         OUT   PORTA, R16 ;1 cycle

loop1:
         NOP
         ADD   R16, R17
         CPI   R16, R20 ;1 cycle
         BRNE  loop1
init2:
         LDI   R16, 0 ;1 cycle
         LDI   R17, 1 ;1 cycle
         LDI   R18, $FF ;1 cycle
         NOP
         OUT   PORTA, R18
loop2:
         NOP
         ADD   R16, R17
         CPI   R16, R20
         BRNE  loop2
rloop:
         RJMP  chkin ;repeat above inst's