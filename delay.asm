.cseg
;================================================================================================
; задержка на 255
;
delay255:
			push r16
			ldi r16,$ff

delay255_0:
			cpi		r16,$00			;1
			breq	delay255_exit	;2
			dec		r16				;1
			rjmp	delay255_0		;2
delay255_exit:

			pop r16
ret
;================================================================================================
; задержка на 20 ms
;
delay20ms:
				ldi		r16,0x17

delay20_0:
				cpi		r16,0x00			;1
				breq	delay20_exit		;2
				
				ldi		r17,0xff			;1
delay20_1:
				cpi		r17,0x00			;1
				breq 	delay20_2			;2

				dec 	r17					;1
				rjmp	delay20_1			;2

delay20_2:
				dec		r16					;1
				rjmp	delay20_0			;2

delay20_exit:
ret
;================================================================================================
; задержка на СЕКУНДЫ
; в r16 секунды
; 1 сек
; 2 сек
; 3 сек
;
;
;
delay_sec:
				push	r17
				push 	r18
				push	r19

				cpi		r16,0x01
				breq	delay_sec_1s

				cpi		r16,0x02
				breq	delay_sec_2s

				cpi		r16,0x03
				breq	delay_sec_3s

				;любое другой коэфициент будет возвращен к 3 сек
				ldi		r19,0x42
				rjmp 	delay_sec_start				


delay_sec_1s:	ldi		r19,0x14
				rjmp 	delay_sec_start				

delay_sec_2s:	ldi		r19,0x2c
				rjmp 	delay_sec_start				

delay_sec_3s:	ldi		r19,0x42
				rjmp 	delay_sec_start				




delay_sec_start:

				ldi		r16,0xff

delay_sec_0:
				cpi		r16,0x00
				breq	delay_sec_exit
				
				ldi		r17,0xff

delay_sec_1:
				cpi		r17,0x00
				breq 	delay_sec_2

									;0x14 - 1 сек
									;0x2c - 2 сек
									;0x42 - 3 сек
				;ldi		r18,0x42
				mov 	r18,r19		;заносим необходимый коэфициент
delay_sec_4:
				cpi		r18,0x00
				breq	delay_sec_3

				dec		r18
				rjmp	delay_sec_4


delay_sec_3:


				dec 	r17
				rjmp	delay_sec_1
delay_sec_2:
				dec		r16
				rjmp	delay_sec_0



delay_sec_exit:

				pop		r19
				pop		r18
				pop		r17

				ret
;================================================================================================
