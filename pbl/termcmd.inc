;
; Filename: termcmd.inc
; Description: Subroutine used for terminal commands.
;
; Author: nsw
;
; Changelog:
; 2023-12-17: File created






n_getch:
    IN    R24, PINB
    ANDI  R24, $01
    BREQ  n_getch_ret
    in    R16, UCSRA
    ANDI  R16, $80
    BREQ  n_getch
    IN    R16, UDR

n_getch_ret:
    RET

n_outch:	
    out   UDR, R16		;txmt char. out the TxD 
n_pollsr:		
    in    R18, UCSRA 	
    andi  R18, $20   	
    breq  n_pollsr
    RET