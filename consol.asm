;===============================================================================
; Подпрограмыы обработки консоли 9600 8N1
;===============================================================================
.dseg
.equ	CONSOL_BUF_LEN	= 80;255

consol_buf: 		.byte CONSOL_BUF_LEN
consol_n: 			.byte 1
consol_flag: 		.byte 1


.equ	CONSOL_FLAG_NONE		= 0
.equ	CONSOL_FLAG_CR			= 1
.equ	CONSOL_FLAG_BS			= 2
.equ	CONSOL_FLAG_OVERFLOW	= 3



.equ	CONSOL_BACKSPACE	= 0x08
.equ	CONSOL_CR	 		= 0x0D
.cseg


;===============================================================================
; инит usart2 9600 8N1
;
;===============================================================================
consol_init:
					clr		r16
					sts		consol_n,r16
					
					ldi		r16,CONSOL_FLAG_NONE
					sts		consol_flag,r16


                	ldi     temp,(((TCLC/Baud9600)/16)-1)       ;115200   Baud230400
                	sts     UBRR2L,temp

					ldi 	r16, 0b10011000		; включаем передатчик и приемник
					sts 	UCSR2B,r16

					ldi 	r16, 0b00000110		; формат кадра 8N1
					sts 	UCSR2C,r16

ret

;===============================================================================
; Принят байт
;
;===============================================================================
USART2_RXC:
					push	r16
					in		r16,sreg
					push	r16
					push	r17
					push	r18
					push	yl
					push	yh





					lds 	r16,UDR2
					sts 	UDR2,r16

					; проверка место перед сохраненнием
					lds		r17,consol_n
					cpi		r17,(CONSOL_BUF_LEN-1)
					brlo	_usart2_r_w			; перейти если меньше !

					ldi		r16,CONSOL_FLAG_OVERFLOW
					sts		consol_flag,r16

					rjmp	_usart2_r_e
_usart2_r_w:
; проверка пришедщего байте на коней строки и т.п.
					cpi		r16,CONSOL_CR
					breq	_usart2_r_cr
					cpi		r16,CONSOL_BACKSPACE
					breq	_usart2_r_bs

;сохраняем принятый байт
                	ldi     yh,high(consol_buf)
                	ldi     yl,low(consol_buf)
					
					clr		r18
					add		yl,r17
					adc		yh,r18

					st		y,r16

					inc		r17				;consol_n++
					sts		consol_n,r17
					rjmp	_usart2_r_e
_usart2_r_cr:
					ldi		r16,CONSOL_CR
					sts		consol_flag,r16
					rjmp	_usart2_r_e

_usart2_r_bs:
					ldi		r16,CONSOL_FLAG_BS
					sts		consol_flag,r16
					rjmp	_usart2_r_e

_usart2_r_e:
					pop		yh
					pop		yl
					pop		r18
					pop		r17
					pop		r16
					out		sreg,r16
					pop		r16
reti

;===============================================================================
; обработка данных из консоли
; основная подпрограмма обработки вызывается в главном цикле
;===============================================================================
consol_cmd_parse:
					lds		r16,consol_flag

					cpi		r16,CONSOL_CR
					breq	_consol_cmd_p_cr

					cpi		r16,CONSOL_FLAG_BS
					breq	_consol_cmd_p_bs

					cpi		r16,CONSOL_FLAG_OVERFLOW
					breq	_consol_cmd_p_overflow
					ret

_consol_cmd_p_cr:
					call	consol_find_cmd
					ret

_consol_cmd_p_bs:
					call	consol_del_char
					ret		

_consol_cmd_p_overflow:
					call	consol_error_overflow
					ret

;===============================================================================
;
;===============================================================================
consol_find_cmd:
; если пустая строка тоо выдаем приглашение
					lds		r16,consol_n
					cpi		r16,0
					;breq	_consol_find_cmd_h
					brne	_consol_find_cmd_next0
					
					call	run_cmd_help_mini
					call	consol_out_path
					ret
_consol_find_cmd_next0:
					ldi 		yl,low (consol_buf)	; строка из RAM
					ldi 		yh,high (consol_buf)

					ldi 		zl,low (CONSOL_CMD_HELP*2)	; строка из ROM
					ldi 		zh,high (CONSOL_CMD_HELP*2)

					call		cmp_string		; сравниваем
;					brts		_error_AT1		;переходим если флаг установлен
					;brcc		_consol_find_cmd_help		;совпадает ответ
					brcs		_consol_find_cmd_next1		;НЕ совпадает ответ

					call	run_cmd_help
					call	consol_out_path
					ret

_consol_find_cmd_next1:
					ldi 		yl,low (consol_buf)	; строка из RAM
					ldi 		yh,high (consol_buf)

					ldi 		zl,low (CONSOL_CMD_HELP1*2)	; строка из ROM
					ldi 		zh,high (CONSOL_CMD_HELP1*2)

					call		cmp_string		; сравниваем
;					brts		_error_AT1		;переходим если флаг установлен
					brcs		_consol_find_cmd_next2		;НЕ совпадает ответ

					call	run_cmd_help
					call	consol_out_path
					ret

_consol_find_cmd_next2:
					ldi 		yl,low (consol_buf)	; строка из RAM
					ldi 		yh,high (consol_buf)

					ldi 		zl,low (CONSOL_CMD_VIEW*2)	; строка из ROM
					ldi 		zh,high (CONSOL_CMD_VIEW*2)

					call		cmp_string		; сравниваем
					brcs		_consol_find_cmd_next3		;НЕ совпадает ответ

					call	run_cmd_view
					call	consol_out_path
					ret
_consol_find_cmd_next3:
					ldi 		yl,low (consol_buf)	; строка из RAM
					ldi 		yh,high (consol_buf)

					ldi 		zl,low (CONSOL_CMD_SN*2)	; строка из ROM
					ldi 		zh,high (CONSOL_CMD_SN*2)

					call		cmp_string		; сравниваем
					brcs		_consol_find_cmd_next4		;НЕ совпадает ответ

					call	run_cmd_sn
					call	consol_clr
					call	consol_out_path
					ret
_consol_find_cmd_next4:
					ldi 		yl,low (consol_buf)	; строка из RAM
					ldi 		yh,high (consol_buf)

					ldi 		zl,low (CONSOL_CMD_TXT*2)	; строка из ROM
					ldi 		zh,high (CONSOL_CMD_TXT*2)

					call		cmp_string		; сравниваем
					brcs		_consol_find_cmd_next5		;НЕ совпадает ответ

					call	run_cmd_txt
					call	consol_clr
					call	consol_out_path
					ret
_consol_find_cmd_next5:
					ldi 		yl,low (consol_buf)	; строка из RAM
					ldi 		yh,high (consol_buf)

					ldi 		zl,low (CONSOL_CMD_PASSWORD*2)	; строка из ROM
					ldi 		zh,high (CONSOL_CMD_PASSWORD*2)

					call		cmp_string		; сравниваем
					brcs		_consol_find_cmd_next6		;НЕ совпадает ответ

					call	run_cmd_password
					call	consol_clr
					call	consol_out_path
					ret
_consol_find_cmd_next6:
					ldi 		yl,low (consol_buf)	; строка из RAM
					ldi 		yh,high (consol_buf)

					ldi 		zl,low (CONSOL_CMD_LOGIN*2)	; строка из ROM
					ldi 		zh,high (CONSOL_CMD_LOGIN*2)

					call		cmp_string		; сравниваем
					brcs		_consol_find_cmd_next7		;НЕ совпадает ответ

					call	run_cmd_login
					call	consol_clr
					call	consol_out_path
					ret
_consol_find_cmd_next7:
					ldi 		yl,low (consol_buf)	; строка из RAM
					ldi 		yh,high (consol_buf)

					ldi 		zl,low (CONSOL_CMD_APNSERV*2)	; строка из ROM
					ldi 		zh,high (CONSOL_CMD_APNSERV*2)

					call		cmp_string		; сравниваем
					brcs		_consol_find_cmd_next8		;НЕ совпадает ответ

					call	run_cmd_apnserv
					call	consol_clr
					call	consol_out_path
					ret
_consol_find_cmd_next8:
					ldi 		yl,low (consol_buf)	; строка из RAM
					ldi 		yh,high (consol_buf)

					ldi 		zl,low (CONSOL_CMD_TELLIST*2)	; строка из ROM
					ldi 		zh,high (CONSOL_CMD_TELLIST*2)

					call		cmp_string		; сравниваем
					brcs		_consol_find_cmd_next9		;НЕ совпадает ответ

					call	run_cmd_tellist
					call	consol_clr
					call	consol_out_path
					ret
_consol_find_cmd_next9:









					call	consol_out_error
					call	consol_clr
					call	consol_out_path

					ret
;===============================================================================
;===============================================================================
run_cmd_tellist:
					call	consol_out_crlf

					ldi 	yl,low (decode_txt_str)
					ldi 	yh,high (decode_txt_str)

;					adiw	yl,1					; 0- байт длинна

					ldi		zl,low(telephone_list*2)
					ldi		zh,high(telephone_list*2)
					call	consol_tx_rom

					call	consol_out_crlf

					call	tel_list_all

;добавляем 00 в конце для правильного перевода в PDU
					ldi		r16,0x00	; последний 00 обязательно
					st		y,r16
					
					ldi		zl,low(decode_txt_str)
					ldi		zh,high(decode_txt_str)
					call	consol_tx_ram

					ret


;===============================================================================
run_cmd_apnserv:
; проверяем длинну строки
					lds		r16,consol_n

					cpi		r16,CONSOL_CMD_APNSERV_LEN
					brlo	_run_cmd_apnserv

_run_cmd_apnserv_er:
					call	consol_out_error
					ret

_run_cmd_apnserv:
; проверяем наличие ковычек в строке (в начале строки после =, и в конце)

					ldi		r16,CONSOL_CMD_NAMEAPNSERV_LEN

					lds		r17,consol_n
					
					ldi		xl,low(consol_buf)
					ldi		xh,high(consol_buf)

					call	str_chr_cc
					brcs	_run_cmd_apnserv_er

; вычисление длинны строки внутри ковычек
					lds		r16,consol_n
					ldi		r17,CONSOL_CMD_NAMEAPNSERV_LEN

					inc		r17;+1+1 - 'это ковычки
					inc 	r17

					sub		r16,r17


					ldi 	xl,low (consol_buf)	; строка из RAM
					ldi 	xh,high (consol_buf)

					adiw	xl,CONSOL_CMD_NAMEAPNSERV_LEN+1		;x=начало серийного номера

					ldi 	zl,low (tcp_apn_serv)	; строка из RAM
					ldi 	zh,high (tcp_apn_serv)
					
					call	copy_x_to_eeprom

ret
;===============================================================================
run_cmd_login:
; проверяем длинну строки
					lds		r16,consol_n

					cpi		r16,CONSOL_CMD_LOGIN_LEN
					brlo	_run_cmd_login

_run_cmd_login_er:
					call	consol_out_error
					ret

_run_cmd_login:
; проверяем наличие ковычек в строке (в начале строки после =, и в конце)

					ldi		r16,CONSOL_CMD_NAMELOGIN_LEN

					lds		r17,consol_n
					
					ldi		xl,low(consol_buf)
					ldi		xh,high(consol_buf)

					call	str_chr_cc
					brcs	_run_cmd_login_er

; вычисление длинны строки внутри ковычек
					lds		r16,consol_n
					ldi		r17,CONSOL_CMD_NAMELOGIN_LEN

					inc		r17;+1+1 - 'это ковычки
					inc 	r17

					sub		r16,r17


					ldi 	xl,low (consol_buf)	; строка из RAM
					ldi 	xh,high (consol_buf)

					adiw	xl,CONSOL_CMD_NAMELOGIN_LEN+1		;x=начало серийного номера

					ldi 	zl,low (tcp_apn_login)	; строка из RAM
					ldi 	zh,high (tcp_apn_login)
					
					call	copy_x_to_eeprom

ret
;===============================================================================
run_cmd_password:
; проверяем длинну строки
					lds		r16,consol_n

					cpi		r16,CONSOL_CMD_PASSWORD_LEN
					brlo	_run_cmd_password

_run_cmd_password_er:
					call	consol_out_error
					ret

_run_cmd_password:
; проверяем наличие ковычек в строке (в начале строки после =, и в конце)

					ldi		r16,CONSOL_CMD_NAMEPASSWORD_LEN

					lds		r17,consol_n
					
					ldi		xl,low(consol_buf)
					ldi		xh,high(consol_buf)

					call	str_chr_cc
					brcs	_run_cmd_password_er

; вычисление длинны строки внутри ковычек
					lds		r16,consol_n
					ldi		r17,CONSOL_CMD_NAMEPASSWORD_LEN

					inc		r17;+1+1 - 'это ковычки
					inc 	r17

					sub		r16,r17


					ldi 	xl,low (consol_buf)	; строка из RAM
					ldi 	xh,high (consol_buf)

					adiw	xl,CONSOL_CMD_NAMEPASSWORD_LEN+1		;x=начало серийного номера

					ldi 	zl,low (tcp_apn_password)	; строка из RAM
					ldi 	zh,high (tcp_apn_password)
					
					call	copy_x_to_eeprom

ret
;===============================================================================
run_cmd_txt:
; проверяем длинну строки
					lds		r16,consol_n

					cpi		r16,CONSOL_CMD_TXT_LEN
					brlo	_run_cmd_txt	

_run_cmd_txt_er:
					call	consol_out_error
					ret

_run_cmd_txt:
; проверяем наличие ковычек в строке (в начале строки после =, и в конце)

					ldi		r16,CONSOL_CMD_NAMETXT_LEN

					lds		r17,consol_n
					
					ldi		xl,low(consol_buf)
					ldi		xh,high(consol_buf)

					call	str_chr_cc
					brcs	_run_cmd_txt_er

; вычисление длинны строки внутри ковычек
					lds		r16,consol_n
					ldi		r17,CONSOL_CMD_NAMETXT_LEN

					inc		r17;+1+1 - 'это ковычки
					inc 	r17

					sub		r16,r17



					ldi 	xl,low (consol_buf)	; строка из RAM
					ldi 	xh,high (consol_buf)

					adiw	xl,CONSOL_CMD_NAMETXT_LEN+1		;x=начало серийного номера

					ldi 	zl,low (s_txt)	; строка из RAM
					ldi 	zh,high (s_txt)
					
					call	copy_x_to_eeprom

ret
;===============================================================================
run_cmd_sn:

; проверяем длинну строки
					lds		r16,consol_n

					cpi		r16,CONSOL_CMD_SN_LEN
					breq	_run_cmd_sn	

					call	consol_out_error
					ret

_run_cmd_sn:
					ldi 		xl,low (consol_buf)	; строка из RAM
					ldi 		xh,high (consol_buf)

					adiw		xl,3		;y=начало серийного номера
					
					call	copy_sn_to_eeprom

ret
;===============================================================================
run_cmd_view:
					call	consol_clr

					ldi		zl,low(consol_view*2)
					ldi		zh,high(consol_view*2)
					call	consol_tx_rom

					call	consol_out_crlf

					ldi		zl,low(version_soft_udu*2)
					ldi		zh,high(version_soft_udu*2)
					call	consol_tx_rom

					call	consol_out_crlf

					ldi		zl,low(version_hard_udu*2)
					ldi		zh,high(version_hard_udu*2)
					call	consol_tx_rom

					call	consol_out_crlf

; SN устройства
					ldi		zl,low(consol_view_sn*2)
					ldi		zh,high(consol_view_sn*2)
					call	consol_tx_rom

					ldi		zl,low(s_sn)
					ldi		zh,high(s_sn)
					call	eeprom_read_byte		; R символ

					cpi		r16,0xff
					breq	_run_cmd_v_nodata		; переходим поле не заполнено

					call	consol_tx_char

					adiw	zl,0x01
					call	eeprom_read_byte		; R символ
	
					call	consol_tx_char

					adiw	zl,0x01
					call	eeprom_read_byte		; R символ

					call	consol_tx_char

					adiw	zl,0x01
					call	eeprom_read_byte		; R символ

					call	consol_tx_char

					rjmp	_run_cmd_v_txt

_run_cmd_v_nodata:
					call	consol_out_udv

					call	consol_out_crlf
_run_cmd_v_txt:
; текстовое описание устройства
					ldi		zl,low(consol_view_txt*2)
					ldi		zh,high(consol_view_txt*2)
					call	consol_tx_rom

					ldi		zl,low(s_txt)
					ldi		zh,high(s_txt)
					call	eeprom_read_byte		; R символ

					cpi		r16,(61)
					brsh	_run_cmd_v_txt_nodata

					mov		r17,r16					; сохранили количество байт для копирывания в счетчике

					rjmp	_run_cmd_v_txt_cp
_run_cmd_v_txt_nodata:
					call	consol_out_udv

					rjmp	_run_cmd_v_psw

_run_cmd_v_txt_cp:
					call	consol_out_from_eeprom
_run_cmd_v_psw:
; PASWORD
					ldi		zl,low(consol_view_psw*2)
					ldi		zh,high(consol_view_psw*2)
					call	consol_tx_rom

					ldi		zl,low(tcp_apn_password)
					ldi		zh,high(tcp_apn_password)
					call	eeprom_read_byte

					cpi		r16,0xff
					breq	_run_cmd_v_psw_nodate
					
					mov		r17,r16

					call	consol_out_from_eeprom
					rjmp	_run_cmd_v_login
_run_cmd_v_psw_nodate:
					call	consol_out_udv
_run_cmd_v_login:
; Login
					ldi		zl,low(consol_view_login*2)
					ldi		zh,high(consol_view_login*2)
					call	consol_tx_rom

					ldi		zl,low(tcp_apn_login)
					ldi		zh,high(tcp_apn_login)
					call	eeprom_read_byte

					cpi		r16,0xff
					breq	_run_cmd_v_login_nodate
					
					mov		r17,r16

					call	consol_out_from_eeprom
					rjmp	_run_cmd_v_apnserver
_run_cmd_v_login_nodate:
					call	consol_out_udv
_run_cmd_v_apnserver:
; apn server
					ldi		zl,low(consol_view_apnserv*2)
					ldi		zh,high(consol_view_apnserv*2)
					call	consol_tx_rom

					ldi		zl,low(tcp_apn_serv)
					ldi		zh,high(tcp_apn_serv)
					call	eeprom_read_byte

					cpi		r16,0xff
					breq	_run_cmd_v_apnserver_nodate
					
					mov		r17,r16

					call	consol_out_from_eeprom
					rjmp	_run_cmd_v_exit
_run_cmd_v_apnserver_nodate:
					call	consol_out_udv
_run_cmd_v_exit:
					call	consol_out_crlf
					;call	consol_out_path
ret
;===============================================================================
; вывод из eeprom в консоль Z - in R17-len
consol_out_from_eeprom:
					adiw	zl,0x01
					call	eeprom_read_byte		; R символ
					
					call	consol_tx_char

					dec		r17

					cpi		r17,0x00
					brne	consol_out_from_eeprom
ret
;===============================================================================
consol_out_udv:
					ldi		zl,low(consol_view_udv*2)
					ldi		zh,high(consol_view_udv*2)
					call	consol_tx_rom
ret
;===============================================================================
consol_out_error:
					ldi		zl,low(consol_error*2)
					ldi		zh,high(consol_error*2)
					call	consol_tx_rom
ret
;===============================================================================
consol_out_crlf:
					ldi		zl,low(consol_str_crlf*2)
					ldi		zh,high(consol_str_crlf*2)
					call	consol_tx_rom
ret

consol_out_cr:
					ldi		r16,CR
					call	consol_tx_char
ret
;===============================================================================
; подпрограммы выполнения команд с консоли
;===============================================================================
run_cmd_help:
					call	consol_clr

					ldi		zl,low(consol_help0*2)
					ldi		zh,high(consol_help0*2)
					call	consol_tx_rom

					call	get_vv_hard
					cpi		r16,VV_HARD_48
					breq	_run_cmd_help48

					ldi		zl,low(consol_help220*2)
					ldi		zh,high(consol_help220*2)
					call	consol_tx_rom
					rjmp 	_run_cmd_help220_48

_run_cmd_help48:
					ldi		zl,low(consol_help48*2)
					ldi		zh,high(consol_help48*2)
					call	consol_tx_rom


_run_cmd_help220_48:
					ldi		zl,low(consol_help1*2)
					ldi		zh,high(consol_help1*2)
					call	consol_tx_rom

					ldi		zl,low(consol_help2*2)
					ldi		zh,high(consol_help2*2)
					call	consol_tx_rom

					;ldi		zl,low(consol_help3*2)
					;ldi		zh,high(consol_help3*2)
					;call	consol_tx_rom

					ldi		zl,low(consol_help4*2)
					ldi		zh,high(consol_help4*2)
					call	consol_tx_rom

					ldi		zl,low(consol_help5*2)
					ldi		zh,high(consol_help5*2)
					call	consol_tx_rom

					ldi		zl,low(consol_help6*2)
					ldi		zh,high(consol_help6*2)
					call	consol_tx_rom

					ldi		zl,low(consol_help7*2)
					ldi		zh,high(consol_help7*2)
					call	consol_tx_rom

					ldi		zl,low(consol_help8*2)
					ldi		zh,high(consol_help8*2)
					call	consol_tx_rom

					ldi		zl,low(consol_help9*2)
					ldi		zh,high(consol_help9*2)
					call	consol_tx_rom


					;call	consol_out_path
ret
;===============================================================================
run_cmd_help_mini:
					call	consol_clr
; выводим строку приглашение

					ldi		zl,low(consol_help_min*2)
					ldi		zh,high(consol_help_min*2)
					call	consol_tx_rom

					;call	consol_out_path
ret
;===============================================================================
consol_out_path:
					ldi		zl,low(consol_path*2)
					ldi		zh,high(consol_path*2)
					call	consol_tx_rom
ret
;===============================================================================
;===============================================================================
;===============================================================================
;===============================================================================
;===============================================================================
;===============================================================================
;===============================================================================
;===============================================================================
;===============================================================================
;===============================================================================
;===============================================================================
;===============================================================================
;===============================================================================
;===============================================================================





;===============================================================================
; удаляем оджин символ из буфера и выводим
;===============================================================================
consol_del_char:
; проверяем есть что удалять вообще ?
					lds		r16,consol_n
					cpi		r16,0x00
					brne	_consol_del_c0

; курсор в начало
					call	consol_out_cr
; затираем строку пробелами
;					ldi		zl,low(consol_str_clr*2)
;					ldi		zh,high(consol_str_clr*2)
;					call	consol_tx_rom
; курсор в начало
;					call	consol_out_cr
; приглашение
					call	consol_out_path

					call	consol_clr
					ret		; пусто выходим
_consol_del_c0:
; курсор в начало
					call	consol_out_cr
; затираем строку пробелами
					ldi		zl,low(consol_str_clr*2)
					ldi		zh,high(consol_str_clr*2)
					call	consol_tx_rom
; курсор в начало
					call	consol_out_cr
; приглашение
					call	consol_out_path

; удаляем один символ из буфера консоли 
					cli
; consol_n--
					lds		r16,consol_n
					dec 	r16
					sts		consol_n,r16
					
; вычисляем адрес конеченого элемента
                	ldi     yh,high(consol_buf)
                	ldi     yl,low(consol_buf)

					clr		r17
					lds		r16,consol_n

					add		yl,r16
					adc		yh,r17

; затираем 0 последний символ					
					ldi		r16,0
					st		y,r16

					sei

; выводим строку из буфера
					ldi		zl,low(consol_buf)
					ldi		zh,high(consol_buf)
					call	consol_tx_ram

					cli
					ldi		r16,CONSOL_FLAG_NONE
					sts		consol_flag,r16
					sei
ret
;===============================================================================
; переполнение буфера консоли. делаем сброс консоли
;===============================================================================
consol_error_overflow:
					call	consol_clr
; выводим строку о том что произошло переполнение консоли

					ldi		zl,low(consol_er_overfolw*2)
					ldi		zh,high(consol_er_overfolw*2)
					call	consol_tx_rom
ret

;===============================================================================
; передать массив из ROM Z /0 конец строки
;===============================================================================
consol_tx_rom:

					lpm		r16,z+

					cpi		r16,0
					breq	_consol_tx_rom_exit
					
					call	consol_tx_char
					
					rjmp	consol_tx_rom

_consol_tx_rom_exit:
ret

;===============================================================================
; передать массив из RAM Z /0 конец строки
;===============================================================================
consol_tx_ram:

					ld		r16,z+

					cpi		r16,0
					breq	_consol_tx_ram_exit
					
					call	consol_tx_char
					
					rjmp	consol_tx_ram

_consol_tx_ram_exit:
ret

;===============================================================================
; передать один символ R16
;===============================================================================
consol_tx_char:
					mov		r0,r16

_consol_tx_wait:
					lds		r16,UCSR2A

					sbrs	r16,UDRE2
					rjmp	_consol_tx_wait

					mov		r16,r0

					sts		UDR2,r16
					ret
;===============================================================================
; сброс консоли
;===============================================================================
consol_clr:
					cli
					clr		r16
					sts		consol_n,r16
					
					ldi		r16,CONSOL_FLAG_NONE
					sts		consol_flag,r16
					sei
ret
;===============================================================================
; str_len		x-in r16-out
;===============================================================================
str_len:
					clr		r16			; count=0

_str_len_c:
					ld		r17,x+
					inc		r16			; count++

					cpi		r17,0
					brne 	_str_len_c

					dec		r16			;-1 тк посчитали 0 в конце строки
ret

;===============================================================================
; проверяем наличие ковычек в строке (в начале строки после =, и в конце)
; r16-длинна команды до ковычки  r17-длинна строки
; x -in
;===============================================================================
str_chr_cc:
;1 кавычка
					push	r17

					clr 	r17
					
					push	xl
					push	xh

					add		xl,r16			
					adc		xh,r17
					
					ld		r16,x

					pop		xh
					pop		xl

					pop		r17
					
					cpi		r16,'"'			
					brne	_str_chr_er0
	
;2 кавычка

					;lds 	r16,consol_n
					mov		r16,r17
					clr		r17
					
					add		xl,r16			
					adc		xh,r17

					sbiw	xl,1		; тепрь указывает на последний символ
					
					ld		r16,x
					
					cpi		r16,'"'			
					brne	_str_chr_er0

					
					clc
					ret

_str_chr_er0:
					sec
ret
;===============================================================================
; X-in
; Z-EEprom  0-байт длинна
; r16 - длинна строки
copy_x_to_eeprom:

					mov		r0,r16

					mov		r3,r16

					mov		r1,zl
					mov		r2,zh

					adiw 	zl,1		; адрес мимо длинны

_copy_x_to_eeprom_n:
					ld			r16,x+					; прочитали байт
					call		eeprom_write_byte		; записали символ
					adiw		zl,0x01		; z=z+1

					dec			r0
					tst			r0						; проверяем все скопировали ?
					breq		_copy_x_to_eeprom_e			; все последний символ (") выходим

					jmp 		_copy_x_to_eeprom_n			; переходим на копирывание следующего символа

_copy_x_to_eeprom_e:
					; сохраняем длинну
					mov		zl,r1
					mov		zh,r2
					mov		r16,r3

					call	eeprom_write_byte		; записали символ
ret
;===============================================================================


CONSOL_CMD_HELP:				.db "HELP",0x00
CONSOL_CMD_HELP1:				.db "?",0x00

CONSOL_CMD_VIEW:				.db "VIEW",0x00

CONSOL_CMD_SN:					.db "SN=",0x00
.equ CONSOL_CMD_SN_LEN = (2+1+4);sn=0000

CONSOL_CMD_TXT:					.db "TXT=",0x00
.equ CONSOL_CMD_NAMETXT_LEN 	= (4);txt=
.equ CONSOL_CMD_TXT_LEN 		= (4+1+60+1);txt="...."

CONSOL_CMD_PASSWORD:			.db "PASSWORD=",0x00
.equ CONSOL_CMD_NAMEPASSWORD_LEN = (9);password=
.equ CONSOL_CMD_PASSWORD_LEN 	= (8+1+15+1);password="...."

CONSOL_CMD_LOGIN:				.db "LOGIN=",0x00
.equ CONSOL_CMD_NAMELOGIN_LEN 	= (6);login=
.equ CONSOL_CMD_LOGIN_LEN 		= (5+1+15+1);login="...."

CONSOL_CMD_APNSERV:				.db "APNSERV=",0x00
.equ CONSOL_CMD_NAMEAPNSERV_LEN 	= (8);apnserv=
.equ CONSOL_CMD_APNSERV_LEN 		= (7+1+60+1);apnserv="...."

CONSOL_CMD_TELLIST:				.db "TELLIST",0x00




consol_str_crlf:				.db	CR,LF,0x00
consol_str_cr:					.db	CR,0x00


consol_er_overfolw:				.db CR,LF,"ERROR:Consol OVERFLOW",CR,LF,"dev>",0x00
consol_path:					.db CR,LF,"dev>",0x00

consol_help_min:				.db CR,LF,"HELP or ?",CR,LF,0x00

consol_help0:					.db CR,LF,"----------------------------------------",0x00

consol_help220:					.db CR,LF,"------------ Device - 220 V -------------",0x00
consol_help48:					.db CR,LF,"------------ Device - 48 V --------------",0x00

consol_help1:					.db CR,LF,"HELP or ?   - This help.",0x00
consol_help2:					.db CR,LF,"VIEW        - Views all variables.",0x00
consol_help4:					.db CR,LF,"SN          - Set serial numer.",0x00
consol_help5:					.db CR,LF,"TXT         - Set text.",0x00
consol_help6:					.db CR,LF,"PASSWORD    - Set APN password.",0x00
consol_help7:					.db CR,LF,"LOGIN       - Set APN login.",0x00
consol_help8:					.db CR,LF,"APNSERV     - Set APN SERVER.",0x00
consol_help9:					.db CR,LF,"TELLIST     - View ALARM Telephone List.",CR,LF,0x00


consol_str_clr:					.db "                                                                                ",0x00; относительно CONSOL_BUF_LEN

consol_view_udv:				.db " Undefined variable ",0x00

consol_error:					.db CR,LF," ERROR ",CR,LF,0x00

consol_view:					.db CR,LF,"-------------------- Device variables --------------------",0x00
consol_view_sn:					.db CR,LF,"SN= ",0x00
consol_view_txt:				.db CR,LF,"TXT= ",0x00
consol_view_psw:				.db CR,LF,"PASSWORD= ",0x00
consol_view_login:				.db CR,LF,"LOGIN= ",0x00
consol_view_apnserv:			.db CR,LF,"APNSERV= ",0x00

