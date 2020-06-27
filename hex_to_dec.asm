;==================================================================================
;	Программа перевода из 16ричного в 10тичный формат
;   1го - байта
;   
;   r17 - in
;	r18 - high 100
;	r19 -      10
;	r20 - low  1
;==================================================================================
hex_to_dec:
			clr		r18
			clr		r19
			clr		r20

hex_to_dec100:
			subi	r17,0x64	 ;-100 dec
			brcs	hex_to_dec10 ; c=1 jmp
			inc		r18
			jmp		hex_to_dec100

hex_to_dec10:
			ldi		r16,0x64
			add		r17,r16
hex_to_dec_100:
			subi	r17,0x0a	;-10
			brcs	hex_to_dec1 ; c=1 jmp
			inc		r19
			jmp		hex_to_dec_100

hex_to_dec1:
			ldi		r16,0x0a
			add		r17,r16
hex_to_dec_1:
			subi	r17,0x01	;-1
			brcs	hex_to_dec_exit ; c=1 jmp
			inc		r20
			jmp		hex_to_dec_1

hex_to_dec_exit:
ret
;==================================================================================
