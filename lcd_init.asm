;==================================================================================
;	��������� ������������� LCD DV-16230
;
;==================================================================================
; �����

.equ	lcd_dc_ddr	= ddrl	; data control => dc
.equ	lcd_dc_port= portl

; data 7654 bit
.equ	lcd_e	=	pl0
.equ	lcd_rs	=	pl1
.equ	lcd_rw	=	pl2 ; ������ � 0 ������������ !
.equ	lcd_led	=	pl3 ; ��������� ���

.equ	lcd_d4	=	pl4
.equ	lcd_d5	=	pl5
.equ	lcd_d6	=	pl6
.equ	lcd_d7	=	pl7

;----------------------------------------------------------------------------------
lcd_init:
; ������� � ������ ��������� ��� ����� �������������
; ����������� �����
			ldi		r16,0xff
			sts		lcd_dc_ddr,r16	; ������������ ����� �� �����

			ldi		r16,(0<<lcd_e)|(0<<lcd_rw)|(0<<lcd_rs)|(1<<lcd_d4)|(1<<lcd_d5)|(1<<lcd_d6)|(1<<lcd_d7)
			sts		lcd_dc_port,r16


; 1 init LCD
			lds		r16,lcd_dc_port
			andi	r16,~(1<<lcd_rs)
			sts		lcd_dc_port,r16

			ldi		r17,0x38;28
			call	lcd_write_tetrada;lcd_write_byte		;������ ����� � ���

		call	del4ms
		call	del4ms

; 2 init LCD
			lds		r16,lcd_dc_port
			andi	r16,~(1<<lcd_rs)
			sts		lcd_dc_port,r16

			ldi		r17,0x38;28
			call	lcd_write_tetrada;lcd_write_byte		;������ ����� � ���

; ����� 200 ��� ���� ����� � 100
		call	delay255	;f=7Mhz 206mks
		call	del4ms



; 3 init LCD
			lds		r16,lcd_dc_port
			andi	r16,~(1<<lcd_rs)
			sts		lcd_dc_port,r16

			ldi		r17,0x38;28
			call	lcd_write_tetrada;lcd_write_byte		;������ ����� � ���
; ��� ���������� 4 ��������� ����

; 4 init LCD
			lds		r16,lcd_dc_port
			andi	r16,~(1<<lcd_rs)
			sts		lcd_dc_port,r16

			ldi		r17,0x28
			call	lcd_write_tetrada;lcd_write_byte		;������ ����� � ���
; ��� ���������� 4 ��������� ����

; 5 init LCD
			lds		r16,lcd_dc_port
			andi	r16,~(1<<lcd_rs)
			sts		lcd_dc_port,r16

			ldi		r17,0x28
			call	lcd_write_byte		;������ ����� � ���
; ��� ���������� 4 ��������� ����

; �������� ����������� ������� ���������
			lds		r16,lcd_dc_port
			andi	r16,~(1<<lcd_rs)
			sts		lcd_dc_port,r16

		ldi		r17,0x0c
		call	lcd_write_byte		;������ ����� � ���

; ����� ������� ��� ������ ������
			lds		r16,lcd_dc_port
			andi	r16,~(1<<lcd_rs)
			sts		lcd_dc_port,r16

		call	del4ms





		ldi		r17,0x06
		call	lcd_write_byte		;������ ����� � ���

;������� ������
			lds		r16,lcd_dc_port
			andi	r16,~(1<<lcd_rs)
			sts		lcd_dc_port,r16

		ldi		r17,0x01
		call	lcd_write_byte		;������ ����� � ���

;������� ������
			lds		r16,lcd_dc_port
			andi	r16,~(1<<lcd_rs)
			sts		lcd_dc_port,r16

		ldi		r17,0x02
		call	lcd_write_byte		;������ ����� � ���



;������� ������ 0
			lds		r16,lcd_dc_port			;RS=1
			ori	r16,(1<<lcd_rs)
			sts		lcd_dc_port,r16

		ldi		r17,0x30
		call	lcd_write_byte		;������ ����� � ���
;������� ������ 0
			lds		r16,lcd_dc_port			;RS=1
			ori	r16,(1<<lcd_rs)
			sts		lcd_dc_port,r16

		ldi		r17,0x30
		call	lcd_write_byte		;������ ����� � ���

;ooo:
;		ldi		r17,'0'
;		call	lcd_write_char
;		
;		rjmp ooo

ret
;=================================================================================
del4ms:
; ����� 4.1 ��
		ldi		r16,0x14		; 20 ���
_lcd_init_1:
		cpi 	r16,0x00
		breq	_lcd_init_2
		call	delay255	;f=7Mhz 206mks
		dec r16
		jmp _lcd_init_1

_lcd_init_2:
ret

