;
; Lab 4 Task 6
; 2023-10-02
; Author : nsw
;

.dseg


.cseg

init1:
         LDI   R16, $FF
         OUT   DDRA, R16

         LDI   R31, HIGH(dspnum<<1)
         LDI   R30, LOW(dspnum<<1)

         LDI   R16, 0
         LDI   R17, 10

loopload:
         LPM   R16, Z+

outloop:
         OUT   PORTA, R16


         DEC   R17
         BRNE  loop1




dspnum   .db   $3F, $06, $5B, $4F, $66, $6D, $7D, $07, $7F, $67