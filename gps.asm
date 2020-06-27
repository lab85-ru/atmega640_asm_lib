.dseg

gps_sync: 			.byte 1					; результат синхронизации со спутниками
gps_rx:		 		.byte 1					; наличие приема данных со стороны GPS приемника
gps_count:	 		.byte 1					; счетчик позиции принятого символа для сравнения со стокой

;temp_count:			.byte 1					; счетчик задержки для измерения температуры
;.equ	TEMP_DELAY			= 10			; величина задержки измерения температуры


.equ	GPS_FLAG_RX_YES		= 1				; есть прием состороны gps
.equ	GPS_FLAG_RX_NO		= 0

.equ	GPS_FLAG_SYNC_CLR			= 0x0
.equ	GPS_FLAG_SYNC_NO			= 0x31
.equ	GPS_FLAG_SYNC_YES_LOW		= 0x32
.equ	GPS_FLAG_SYNC_YES_HIGH		= 0x33

.cseg

GPS_SYNC_STRING:	.db "$GPGSA,A,"
.equ GPS_SYNC_STRING_LEN = 9

LCD_gps:					.db		0x00,0x01,"      GPS       ",0x00		;1-x 2-y
LCD_gps_sync_no:			.db		0x00,0x02,"RX:Ok SYNC:1 No ",0x00		;1-x 2-y
LCD_gps_sync_yes_low:		.db		0x00,0x02,"RX:Ok SYNC:2 2D ",0x00		;1-x 2-y
LCD_gps_sync_yes_high:		.db		0x00,0x02,"RX:Ok SYNC:3 3D ",0x00		;1-x 2-y
LCD_gps_sync_clr:			.db		0x00,0x02,"RX:Ok SYNC:0    ",0x00		;1-x 2-y
;LCD_gps_rx_no:				.db		0x00,0x02,"RX:No           ",0x00		;1-x 2-y
LCD_gps_rx_no:				.db		0x00,0x02,"RX:*************",0x00		;1-x 2-y


;============================================================================
; Включаем uart3 на прием 4800
;============================================================================
gps_uart_on:

                	ldi     r16,(((TCLC/Baud4800)/16)-1)
                	sts     UBRR3L,r16

					clr		r16
					sts     UBRR3H,r16

					ldi 	r16, 0b10010000		; включаем только приемник
					sts 	UCSR3B,r16

					ldi 	r16, 0b00000110		; формат кадра 8data, 1stop bit
					sts 	UCSR3C,r16

ret

;============================================================================
; Выключаем uart3
;============================================================================
gps_uart_off:
					clr		r16
                	sts     UBRR3L,r16
                	sts     UBRR3H,r16
					sts 	UCSR3B,r16
					sts 	UCSR3C,r16
ret


;============================================================================
; инит для GPS
;============================================================================
gps_init:
					clr		r16
					sts		gps_sync,r16
					sts		gps_rx,r16
					sts		gps_count,r16

					call	gps_uart_on

ret

;============================================================================
; основной цикл,
;============================================================================
gps_reciv:

					ldi			r16,0x01				; пауза 1 сек
					call		delay_sec

;					call		lcd_clr			;очистили ЖКИ
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
					ldi			zl,low  (LCD_gps*2)
					ldi			zh,high (LCD_gps*2)
					call		lcd_write_string;вывод строки на экран
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

					lds		r16,gps_rx
					
					cpi		r16,GPS_FLAG_RX_YES
					breq	_gps_reciv_for_flag_rx

					ldi		r16,GPS_FLAG_SYNC_CLR		; сбрасываем предыдущее состосняие
					sts		gps_sync,r16

;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
					ldi			zl,low  (LCD_gps*2)
					ldi			zh,high (LCD_gps*2)
					call		lcd_write_string;вывод строки на экран
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
					ldi			zl,low  (LCD_gps_rx_no*2)
					ldi			zh,high (LCD_gps_rx_no*2)
					call		lcd_write_string;вывод строки на экран
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
					;rjmp	_gps_reciv_for					
					ret

_gps_reciv_for_flag_rx:

					ldi		r16,GPS_FLAG_RX_NO
					sts		gps_rx,r16


					lds		r16,gps_sync

					cpi		r16,GPS_FLAG_SYNC_NO			; прием есть синхронизации нет
					breq	gps_rf_sync_no
					cpi		r16,GPS_FLAG_SYNC_YES_LOW		; прием есть синхронизация есть 2D
					breq	gps_rf_sync_yes_low
					cpi		r16,GPS_FLAG_SYNC_YES_HIGH		; прием есть синхронизации есть 3D
					breq	gps_rf_sync_yes_high
					cpi		r16,GPS_FLAG_SYNC_CLR			; пустой флаг нет информации
					breq	gps_rf_sync_clr

					;rjmp 	_gps_reciv_for
ret

gps_rf_sync_no:
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
					ldi			zl,low  (LCD_gps*2)
					ldi			zh,high (LCD_gps*2)
					call		lcd_write_string;вывод строки на экран
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
					ldi			zl,low  (LCD_gps_sync_no*2)
					ldi			zh,high (LCD_gps_sync_no*2)
					call		lcd_write_string;вывод строки на экран
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
					;rjmp 	_gps_reciv_for
					ret

gps_rf_sync_yes_low:
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
					ldi			zl,low  (LCD_gps*2)
					ldi			zh,high (LCD_gps*2)
					call		lcd_write_string;вывод строки на экран
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
					ldi			zl,low  (LCD_gps_sync_yes_low*2)
					ldi			zh,high (LCD_gps_sync_yes_low*2)
					call		lcd_write_string;вывод строки на экран
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
					;rjmp 	_gps_reciv_for
					ret


gps_rf_sync_yes_high:
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
					ldi			zl,low  (LCD_gps*2)
					ldi			zh,high (LCD_gps*2)
					call		lcd_write_string;вывод строки на экран
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
					ldi			zl,low  (LCD_gps_sync_yes_high*2)
					ldi			zh,high (LCD_gps_sync_yes_high*2)
					call		lcd_write_string;вывод строки на экран
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
					;rjmp 	_gps_reciv_for
					ret


gps_rf_sync_clr:
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
					ldi			zl,low  (LCD_gps*2)
					ldi			zh,high (LCD_gps*2)
					call		lcd_write_string;вывод строки на экран
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
					ldi			zl,low  (LCD_gps_sync_clr*2)
					ldi			zh,high (LCD_gps_sync_clr*2)
					call		lcd_write_string;вывод строки на экран
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
					;rjmp 	_gps_reciv_for
					ret




;===============================================================================
; Принят байт
;
;===============================================================================
USART3_RXC:
					push	r16
					in		r16,sreg
					push	r16
					push	r17
					push	r18
					push	zl
					push	zh

					lds 	r18,UDR3

					ldi		r16,GPS_FLAG_RX_YES
					sts		gps_rx,r16


					lds		r16,gps_count
;					inc 	r16
;					sts		gps_count,r16

					cpi		r16,GPS_SYNC_STRING_LEN
					brne	_usart3_r_no

					sts		gps_sync,r18

					clr		r16
					sts		gps_count,r16

					rjmp	_usart3_r_e

_usart3_r_no:
					ldi		zl,low  (GPS_SYNC_STRING*2)
					ldi		zh,high (GPS_SYNC_STRING*2)

					clr		r17
					add		zl,r16		;r16=gps_count
					adc		zh,r17
					
					lpm		r17,z
					
					cp		r18,r17		;RXchar = GPS_SYNC_STRING[count] ?
					breq	_usart3_r_count



					clr		r16
					sts		gps_count,r16

_usart3_r_e:
					pop		zh
					pop		zl
					pop		r18
					pop		r17
					pop		r16
					out		sreg,r16
					pop		r16
reti


_usart3_r_count:
					lds		r16,gps_count
					inc 	r16
					sts		gps_count,r16
					rjmp	_usart3_r_e


