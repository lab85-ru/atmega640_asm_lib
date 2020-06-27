;================================================================================================================
;	подпрограмма тестирывания внешней памяти !
;	
; 	X	-	адресс начала
;	Y	-	конец 
;
;
;
;================================================================================================================
ram_test:



_ram_test_loop:

; записали - считали 0
				ldi		r16,0x00
				st		x,r16
				nop
				ld		r17,x

				cp		r16,r17
				brne	_ram_test_error

; записали - считали AA
				ldi		r16,0xaa
				st		x,r16
				nop
				ld		r17,x

				cp		r16,r17
				brne	_ram_test_error

; записали - считали 55
				ldi		r16,0x55
				st		x,r16
				nop
				ld		r17,x

				cp		r16,r17
				brne	_ram_test_error

; записали - считали ff
				ldi		r16,0xff
				st		x,r16
				nop
				ld		r17,x

				cp		r16,r17
				brne	_ram_test_error


				cp		xh,yh
				brne	_ram_test_add
				cp		xl,yl
				breq	_ram_test_exit
_ram_test_add:
				adiw	xl,0x01
				rjmp	_ram_test_loop

_ram_test_exit:
				clt
				ret

_ram_test_error:
				set
				ret
;================================================================================================================
