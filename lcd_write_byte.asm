;==================================================================================
;	Запись байта на LCD DV-16230
; 
;
;==================================================================================
; порты

;----------------------------------------------------------------------------------
lcd_write_byte:
				push 	r17
				andi	r17,0xf0	; high tetrad

				lds		r16,lcd_dc_port
				andi	r16,0x0f
				add		r16,r17
				sts		lcd_dc_port,r16

				call	delay255	;f=7Mhz 206mks
				call	delay255	;f=7Mhz 206mks
				call	delay255	;f=7Mhz 206mks

				lds		r16,lcd_dc_port
				ori		r16,(1<<lcd_e)
				sts		lcd_dc_port,r16

				call	delay255	;f=7Mhz 206mks
				call	delay255	;f=7Mhz 206mks

				call	delay255	;f=7Mhz 206mks
				call	delay255	;f=7Mhz 206mks
				;call	delay255	;f=7Mhz 206mks
				;call	delay255	;f=7Mhz 206mks
				;call	delay255	;f=7Mhz 206mks
				;call	delay255	;f=7Mhz 206mks
				;call	delay255	;f=7Mhz 206mks
				;call	delay255	;f=7Mhz 206mks

				lds		r16,lcd_dc_port
				andi	r16,~(1<<lcd_e)
				sts		lcd_dc_port,r16

				call	delay255	;f=7Mhz 206mks
				call	delay255	;f=7Mhz 206mks				
				call	delay255	;f=7Mhz 206mks

;				in		r17,lcd_dc_port
;				ori		r17,(1<<lcd_d4)|(1<<lcd_d5)|(1<<lcd_d6)|(1<<lcd_d7)
;				out		lcd_dc_port,r17	;lcd_data=0xff

;				call	delay255	;f=7Mhz 206mks
;				call	delay255	;f=7Mhz 206mks


; low tetrad
				pop		r17

				rol		r17
				rol		r17
				rol		r17
				rol		r17
				andi	r17,0xf0

				lds		r16,lcd_dc_port
				andi	r16,0x0f
				add		r16,r17
				sts		lcd_dc_port,r16

				call	delay255	;f=7Mhz 206mks
				call	delay255	;f=7Mhz 206mks
				call	delay255	;f=7Mhz 206mks

				lds		r16,lcd_dc_port
				ori		r16,(1<<lcd_e)
				sts		lcd_dc_port,r16

				call	delay255	;f=7Mhz 206mks
				call	delay255	;f=7Mhz 206mks
				call	delay255	;f=7Mhz 206mks

				call	delay255	;f=7Mhz 206mks
				call	delay255	;f=7Mhz 206mks
				;call	delay255	;f=7Mhz 206mks
				;call	delay255	;f=7Mhz 206mks
				;call	delay255	;f=7Mhz 206mks
				;call	delay255	;f=7Mhz 206mks
				;call	delay255	;f=7Mhz 206mks
				;call	delay255	;f=7Mhz 206mks

				lds		r16,lcd_dc_port
				andi	r16,~(1<<lcd_e)
				sts		lcd_dc_port,r16

				call	delay255	;f=7Mhz 206mks
				call	delay255	;f=7Mhz 206mks				
				call	delay255	;f=7Mhz 206mks

				lds		r17,lcd_dc_port
				ori		r17,(1<<lcd_d4)|(1<<lcd_d5)|(1<<lcd_d6)|(1<<lcd_d7)
				sts		lcd_dc_port,r17	;lcd_data=0xff

				call	delay255	;f=7Mhz 206mks
				call	delay255	;f=7Mhz 206mks
				call	delay255	;f=7Mhz 206mks
				call	delay255	;f=7Mhz 206mks
				;call	del4ms
ret
;=================================================================================
lcd_write_tetrada:
				andi	r17,0xf0	; high tetrad

				lds		r16,lcd_dc_port
				andi	r16,0x0f
				add		r16,r17
				sts		lcd_dc_port,r16
call	del4ms				
				call	delay255	;f=7Mhz 206mks
				call	delay255	;f=7Mhz 206mks
				call	delay255	;f=7Mhz 206mks

				lds		r16,lcd_dc_port
				ori		r16,(1<<lcd_e)
				sts		lcd_dc_port,r16
call	del4ms
				call	delay255	;f=7Mhz 206mks
				call	delay255	;f=7Mhz 206mks

				call	delay255	;f=7Mhz 206mks
				call	delay255	;f=7Mhz 206mks
				;call	delay255	;f=7Mhz 206mks
				;call	delay255	;f=7Mhz 206mks
				;call	delay255	;f=7Mhz 206mks
				;call	delay255	;f=7Mhz 206mks
				;call	delay255	;f=7Mhz 206mks
				;call	delay255	;f=7Mhz 206mks

				lds		r16,lcd_dc_port
				andi	r16,~(1<<lcd_e)
				sts		lcd_dc_port,r16
call	del4ms
				call	delay255	;f=7Mhz 206mks
				call	delay255	;f=7Mhz 206mks				
				call	delay255	;f=7Mhz 206mks

;				in		r17,lcd_dc_port
;				ori		r17,(1<<lcd_d4)|(1<<lcd_d5)|(1<<lcd_d6)|(1<<lcd_d7)
;				out		lcd_dc_port,r17	;lcd_data=0xff

;				call	delay255	;f=7Mhz 206mks
;				call	delay255	;f=7Mhz 206mks

ret
;================================================================================================
