;==================================================================================
;	Вывод строки на LCD DV-16230
; Формат   <0-поз Х><1-поз Y><строка для вывода><00-код конец строки>
; Z-адресс строки
;==================================================================================
lcd_write_string:

			lpm		r16,z+		;r16=x
			lpm		r17,z+		;r17=y

			cpi		r17,0x00
			breq 	_lcd_wr_string_exit

;вычисляем адрес вывода в ЖКИ
			swap	r17									;переставили местами тетрады
			andi	r17,0x20							;задана строка 2 ?
			lsl		r17									;из 2 получили 4 или 40 адресс второй стоки
			add		r17,r16								;адресс в R17

			ori		r17,0x80

;команда установики адресса
;			cbi		lcd_control_port,lcd_rs				;RS=0
			lds		r16,lcd_dc_port
			andi	r16,~(1<<lcd_rs)
			sts		lcd_dc_port,r16

			;ldi		r17,0x38
			call	lcd_write_byte						;запись байта в ЖКИ

_lcd_wr_string_0:

			lpm 		r17,z+							; читаем символы

			call	lcd_ascii_to_lcd_table				; перекодировка в ascii таблици ЖКИ

			cpi		r17,0x00							;проверка на конец строки
			breq	_lcd_wr_string_exit

;записываем в память символы
;			sbi		lcd_control_port,lcd_rs				;RS=1
			lds		r16,lcd_dc_port
			ori		r16,(1<<lcd_rs)
			sts		lcd_dc_port,r16

			;ldi		r17,0x38
			call	lcd_write_byte						;запись байта в ЖКИ

			jmp _lcd_wr_string_0



_lcd_wr_string_exit:
ret
;=================================================================================
