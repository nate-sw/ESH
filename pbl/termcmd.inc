;
; Filename: termcmd.inc
; Description: Subroutine used for terminal commands.
;
; Author: nsw
;
; Changelog:
; 2023-12-17: File created



 


n_getch_node:
    RCALL systime
    IN    R24, PINB
    ANDI  R24, $01
    BREQ  n_getch_ret
    in    R16, UCSRA
    ANDI  R16, $80
    BREQ  n_getch_node
    IN    R16, UDR
    RJMP  n_getch_ret


n_getch_svr: ;getch used for supervisor mode when time is running.
    IN    R24, PINB
    ANDI  R24, $01
    BRNE  n_getch_ret
    RCALL systime
    RCALL svr_time
    in    R16, UCSRA
    ANDI  R16, $80
    BREQ  n_getch_svr
    IN    R16, UDR
    RJMP  n_getch_ret

n_getch_svr_p: ;getch used for supervisor when time is paused. Near identical to getch used in Node.
    IN    R24, PINB
    ANDI  R24, $01
    BRNE  n_getch_ret
    in    R16, UCSRA
    ANDI  R16, $80
    BREQ  n_getch_svr_p
    IN    R16, UDR
    RJMP  n_getch_ret



n_getch_ret:
    RET

n_outch:	
    out   UDR, R16		;txmt char. out the TxD 
n_pollsr:		
    in    R18, UCSRA 	
    andi  R18, $20   	
    breq  n_pollsr
    RET