;
; Lab 3 Task 1
; 2023-09-18
; Author : nsw
;

.include "m8515def.inc"

init:
         LDI   R16, $FF
         OUT   DDRA, R16 ;config PORTA as all outputs

pt1:
         LDI   R16, $0
         OUT   PORTA, R16 ;send 0x55 PORTA’s pins
init1:

         LDI   R16, $FF
         LDI   R17, 1
loop1:
         ADD   R16, R17
         BRCC  loop1
pt1b:
         LDI   R16, $FF
         OUT   PORTA, R16
init2:

         LDI   R16, $FF
         LDI   R17, 1
loop2:
         ADD   R16, R17
         BRCC  loop2
pt2:
         RJMP  pt1 ;repeat above inst's