;==================================================================================
;	������� LCD FDCC1602
;
;==================================================================================
; �����

;.equ	lcd_data_ddr	= ddrb
;.equ	lcd_control_ddr	= ddre
;.equ	lcd_control_port= porte

;.equ	lcd_data	=	portb	

;.equ	lcd_rs	=	pe6
;.equ	lcd_e	=	pe7

;----------------------------------------------------------------------------------
lcd_clr:
;�������� �����
;										;RS=0
			lds		r16,lcd_dc_port
			andi	r16,~(1<<lcd_rs)
			sts		lcd_dc_port,r16

			ldi		r17,0x01
			call	lcd_write_byte		;������ ����� � ���
;������� ������ � ������
;										;RS=0
			lds		r16,lcd_dc_port
			andi	r16,~(1<<lcd_rs)
			sts		lcd_dc_port,r16

			ldi		r17,0x02
			call	lcd_write_byte		;������ ����� � ���

ret
;=================================================================================
