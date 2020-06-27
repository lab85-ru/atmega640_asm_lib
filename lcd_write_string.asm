;==================================================================================
;	����� ������ �� LCD DV-16230
; ������   <0-��� �><1-��� Y><������ ��� ������><00-��� ����� ������>
; Z-������ ������
;==================================================================================
lcd_write_string:

			lpm		r16,z+		;r16=x
			lpm		r17,z+		;r17=y

			cpi		r17,0x00
			breq 	_lcd_wr_string_exit

;��������� ����� ������ � ���
			swap	r17									;����������� ������� �������
			andi	r17,0x20							;������ ������ 2 ?
			lsl		r17									;�� 2 �������� 4 ��� 40 ������ ������ �����
			add		r17,r16								;������ � R17

			ori		r17,0x80

;������� ���������� �������
;			cbi		lcd_control_port,lcd_rs				;RS=0
			lds		r16,lcd_dc_port
			andi	r16,~(1<<lcd_rs)
			sts		lcd_dc_port,r16

			;ldi		r17,0x38
			call	lcd_write_byte						;������ ����� � ���

_lcd_wr_string_0:

			lpm 		r17,z+							; ������ �������

			call	lcd_ascii_to_lcd_table				; ������������� � ascii ������� ���

			cpi		r17,0x00							;�������� �� ����� ������
			breq	_lcd_wr_string_exit

;���������� � ������ �������
;			sbi		lcd_control_port,lcd_rs				;RS=1
			lds		r16,lcd_dc_port
			ori		r16,(1<<lcd_rs)
			sts		lcd_dc_port,r16

			;ldi		r17,0x38
			call	lcd_write_byte						;������ ����� � ���

			jmp _lcd_wr_string_0



_lcd_wr_string_exit:
ret
;=================================================================================
