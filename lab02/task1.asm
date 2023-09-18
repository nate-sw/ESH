;
; Lab 2 Task 1
; 2023-09-11
; Author : nsw
;
.dseg

id1:	.byte 1
id2:	.byte 1
id3:    .byte 1
id4:    .byte 1
id5:    .byte 1

.org $100
out1:   .byte 1
out2:   .byte 1
out3:   .byte 1
out4:   .byte 1
out5:   .byte 1

.cseg
reset: rjmp start

.org $32
start:
    LDI  R16, 3
    LDI  R17, 2
    LDI  R18, 5
    LDI  R19, 7
    LDI  R20, 4

    STS	 id1, R16
    STS  id2, R17
    STS  id3, R18
    STS  id4, R19
    STS  id5, R20

    LDI  R17, 1

    LDS  R16, id1
    ADD  R16, R17
    STS  out1, R16
    LDS  R16, id2
	ADD  R16, R17
    STS  out2, R16
    LDS  R16, id3
	ADD  R16, R17
    STS  out3, R16
    LDS  R16, id4
	ADD  R16, R17
    STS  out4, R16
    LDS  R16, id5
	ADD  R16, R17
    STS  out5, R16


fini:
	rjmp fini