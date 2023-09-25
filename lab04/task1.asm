;
; Lab 4 Task 1
; 2023-09-25
; Author : nsw
;

.include "m8515def.inc"

.equ     LIM=61

init:
         LDI   R16, $FF ;1 cycle
         OUT   DDRA, R16 ;config PORTA as all outputs - 1 cycle
outinit1:
         LDI   R16, $0 ;1 cycle
         OUT   PORTA, R16
init1:
         LDI   R16, 0 ;1 cycle
         LDI   R17, 1 ;1 cycle
loop1:
         ADD   R16, R17
         CPI   R16, LIM ;1 cycle
         BRNE  loop1
outinit2:
         LDI   R16, $FF ;1 cycle
         OUT   PORTA, R16
init2:
         LDI   R16, 0 ;1 cycle
         LDI   R17, 1 ;1 cycle
loop2:
         ADD   R16, R17
         CPI   R16, LIM
         BRNE  loop2
rloop:
         RJMP  outinit1 ;repeat above inst's