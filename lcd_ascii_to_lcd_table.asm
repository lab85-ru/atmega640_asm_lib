;==================================================================================
;	������� ������������� ��� LCD DV-16230
; ��������� �� ASCII (��) � ASCII (LCD HD44780 ��� ��� ��������)
; r17-in ,   r17-out
;==================================================================================
lcd_ascii_to_lcd_table:

			cpi 	r17,0xc0	; ������ ��� ����� (�������� ������� �������� � ��������� win1251)
			brsh	_lcd_asciitable0
ret

_lcd_asciitable0:
;��� ������� ������ ������������ 
			push	zl
			push	zh

			ldi		zl,low (ascii_to_lcd*2)
			ldi		zh,high(ascii_to_lcd*2)

			mov		r16,r17		;�������� ���� ���������

			andi	r16,0x30	;������� ��� ����� ��������� ������ ������ � ����� �������

			andi	r17,0x0f	;�������� ������� � �������

			clc
			ldi		r18,0x00

			add		zl,r17		;z=z+r17
			adc		zh,r18

			add		zl,r16		;z=z+r16
			adc		zh,r18

			lpm		r17,z

			pop 	zh
			pop		zl
ret
;=================================================================================
ascii_to_lcd:
.db			0x41,0xa0,0x42,0xa1,0xe0,0x45,0xa3,0xa4,0xa4,0xa6,0x4b,0xa7,0x4d,0x48,0x4f,0xa8 ; 0xc0
.db			0x50,0x43,0x54,0xa9,0xaa,0x58,0xe1,0xab,0xac,0xe2,0xad,0xae,0xc4,0xaf,0xb0,0xb1 ; 0xd0
.db			0x61,0xb2,0xb3,0xb4,0xe3,0x65,0xb6,0xb7,0xb8,0xa6,0xba,0xbb,0xbc,0xbd,0x6f,0xbe ; 0xe0
.db			0x70,0x63,0xbf,0x79,0xe4,0x79,0xe5,0xc0,0xc1,0xe2,0xc2,0xc3,0xc4,0xc5,0xc6,0xc7 ; 0xf0
;=================================================================================
