;==================================================================================
;	Начальная инициализация LCD DV-16230
;
;==================================================================================
; порты

.equ	lcd_dc_ddr	= ddrl	; data control => dc
.equ	lcd_dc_port= portl

; data 7654 bit
.equ	lcd_e	=	pl0
.equ	lcd_rs	=	pl1
.equ	lcd_rw	=	pl2 ; всегда в 0 неиспользуем !
.equ	lcd_led	=	pl3 ; подсветка жки

.equ	lcd_d4	=	pl4
.equ	lcd_d5	=	pl5
.equ	lcd_d6	=	pl6
.equ	lcd_d7	=	pl7

;----------------------------------------------------------------------------------
lcd_init:
; выносим в начало программы для одной инициализации
; настраиваем порты
			ldi		r16,0xff
			sts		lcd_dc_ddr,r16	; используемые порты на выход

			ldi		r16,(0<<lcd_e)|(0<<lcd_rw)|(0<<lcd_rs)|(1<<lcd_d4)|(1<<lcd_d5)|(1<<lcd_d6)|(1<<lcd_d7)
			sts		lcd_dc_port,r16


; 1 init LCD
			lds		r16,lcd_dc_port
			andi	r16,~(1<<lcd_rs)
			sts		lcd_dc_port,r16

			ldi		r17,0x38;28
			call	lcd_write_tetrada;lcd_write_byte		;запись байта в ЖКИ

		call	del4ms
		call	del4ms

; 2 init LCD
			lds		r16,lcd_dc_port
			andi	r16,~(1<<lcd_rs)
			sts		lcd_dc_port,r16

			ldi		r17,0x38;28
			call	lcd_write_tetrada;lcd_write_byte		;запись байта в ЖКИ

; пауза 200 мкс хотя можно и 100
		call	delay255	;f=7Mhz 206mks
		call	del4ms



; 3 init LCD
			lds		r16,lcd_dc_port
			andi	r16,~(1<<lcd_rs)
			sts		lcd_dc_port,r16

			ldi		r17,0x38;28
			call	lcd_write_tetrada;lcd_write_byte		;запись байта в ЖКИ
; все установили 4 разрядную шину

; 4 init LCD
			lds		r16,lcd_dc_port
			andi	r16,~(1<<lcd_rs)
			sts		lcd_dc_port,r16

			ldi		r17,0x28
			call	lcd_write_tetrada;lcd_write_byte		;запись байта в ЖКИ
; все установили 4 разрядную шину

; 5 init LCD
			lds		r16,lcd_dc_port
			andi	r16,~(1<<lcd_rs)
			sts		lcd_dc_port,r16

			ldi		r17,0x28
			call	lcd_write_byte		;запись байта в ЖКИ
; все установили 4 разрядную шину

; включаем отображение курсоры выключены
			lds		r16,lcd_dc_port
			andi	r16,~(1<<lcd_rs)
			sts		lcd_dc_port,r16

		ldi		r17,0x0c
		call	lcd_write_byte		;запись байта в ЖКИ

; сдвиг курсора при каждом выводе
			lds		r16,lcd_dc_port
			andi	r16,~(1<<lcd_rs)
			sts		lcd_dc_port,r16

		call	del4ms





		ldi		r17,0x06
		call	lcd_write_byte		;запись байта в ЖКИ

;очистка экрана
			lds		r16,lcd_dc_port
			andi	r16,~(1<<lcd_rs)
			sts		lcd_dc_port,r16

		ldi		r17,0x01
		call	lcd_write_byte		;запись байта в ЖКИ

;очистка экрана
			lds		r16,lcd_dc_port
			andi	r16,~(1<<lcd_rs)
			sts		lcd_dc_port,r16

		ldi		r17,0x02
		call	lcd_write_byte		;запись байта в ЖКИ



;выводим символ 0
			lds		r16,lcd_dc_port			;RS=1
			ori	r16,(1<<lcd_rs)
			sts		lcd_dc_port,r16

		ldi		r17,0x30
		call	lcd_write_byte		;запись байта в ЖКИ
;выводим символ 0
			lds		r16,lcd_dc_port			;RS=1
			ori	r16,(1<<lcd_rs)
			sts		lcd_dc_port,r16

		ldi		r17,0x30
		call	lcd_write_byte		;запись байта в ЖКИ

;ooo:
;		ldi		r17,'0'
;		call	lcd_write_char
;		
;		rjmp ooo

ret
;=================================================================================
del4ms:
; пауза 4.1 мс
		ldi		r16,0x14		; 20 раз
_lcd_init_1:
		cpi 	r16,0x00
		breq	_lcd_init_2
		call	delay255	;f=7Mhz 206mks
		dec r16
		jmp _lcd_init_1

_lcd_init_2:
ret

