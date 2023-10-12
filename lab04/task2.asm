;
; Lab 4 Task 2
; 2023-09-25
; Author : nsw
;

.include "m8515def.inc"

.equ     LIM1 =246 ;500Hz
.equ     LIM2 =121
.equ     LIM3 =78
.equ     LIM4 =58

init:
         LDI   R16, $FF ;1 cycle
         OUT   DDRA, R16 ;config PORTA as all outputs - 1 cycle
         LDI   R16, $00
         OUT   DDRD, R16

outinit1:
         LDI   R16, $0 ;1 cycle
         OUT   PORTA, R16

chkin1:
         NOP
         IN    R18, PIND ;1 cycle
         LDI   R17, $0F
         AND   R18, R17
         CPI   R18, 1 ;1 cycle
         BREQ  dlyinit1 ;1 cycle if false, 2 if true
         CPI   R18, 2
         BREQ  dlyinit2
         CPI   R18, 4
         BREQ  dlyinit3
         CPI   R18, 8
         BREQ  dlyinit4

dlyinit1:
         LDI   R19, LIM1
         NOP
         NOP
         RJMP  init1
dlyinit2:
         LDI   R19, LIM2
         RJMP  init1
dlyinit3:
         NOP
         LDI   R19, LIM3
         NOP
         NOP
         RJMP  init1
dlyinit4:
         LDI   R19, LIM4
         
init1:
         LDI   R16, 0 ;1 cycle
         LDI   R17, 1 ;1 cycle
loop1:
         ADD   R16, R17
         CP    R16, R19 ;1 cycle
         BRNE  loop1
outinit2:
         LDI   R16, $FF ;1 cycle
         OUT   PORTA, R16

chkin2:
         NOP
         NOP
         CPI   R18, 1 ;1 cycle
         BREQ  dly1 ;1 cycle if false, 2 if true
         CPI   R18, 2
         BREQ  dly2
         CPI   R18, 4
         BREQ  dly3
         CPI   R18, 8
         BREQ  dly4

dly1:
         LDI   R19, LIM1
         NOP
         NOP
         RJMP  init2
dly2:
         LDI   R19, LIM2
         RJMP  init2
dly3:
         NOP
         LDI   R19, LIM3
         NOP
         NOP
         RJMP  init2
dly4:
         LDI   R19, LIM4

init2:
         LDI   R16, 0 ;1 cycle
         LDI   R17, 1 ;1 cycle
loop2:
         ADD   R16, R17
         CP    R16, R19
         BRNE  loop2
rloop:
         RJMP  outinit1 ;repeat above inst's