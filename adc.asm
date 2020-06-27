.def var10 = r2
.def var11 = r3
.def var12 = r4
.def var13 = r5

.def var20 = r6
.def var21 = r7
.def var22 = r8
.def var23 = r9

.def mod0 = r10
.def mod1 = r11
.def mod2 = r12
.def mod3 = r13

.def lc = r16

;==================================================================================
; программы начальной инициализации ADC2
;==================================================================================
adc_init2:
					ldi		r16,(1<<aden)|(0<<adate)|(1<<adps2)|(1<<adps1)|(1<<adps0)
					sts		adcsra,r16

					ldi		r16,(1<<refs1)|(1<<refs0)|(1<<mux1)	;adc2 | (1<<adlar)
					sts		admux,r16

					lds		r16,adcsrb
					andi	r16,~( 1 << ACME ) 	;acme=0
					sts		adcsrb,r16
ret

;==================================================================================
; программы начальной инициализации ADC1
;==================================================================================
adc_init1:
					ldi		r16,(1<<aden)|(0<<adate)|(1<<adps2)|(1<<adps1)|(1<<adps0)
					sts		adcsra,r16

					ldi		r16,(1<<refs1)|(1<<refs0)|(1<<adlar)|(1<<mux0)	;adc1
					sts		admux,r16

					lds		r16,adcsrb
					andi	r16,~( 1 << ACME ) 	;acme=0
					sts		adcsrb,r16
ret
;==================================================================================
; программы начальной инициализации ADC0
;==================================================================================
adc_init0:
					ldi		r16,(1<<aden)|(0<<adate)|(1<<adps2)|(1<<adps1)|(1<<adps0)
					sts		adcsra,r16

					ldi		r16,(1<<refs1)|(1<<refs0)|(1<<adlar);|(1<<mux0)	;adc0
					sts		admux,r16

					lds		r16,adcsrb
					andi	r16,~( 1 << ACME ) 	;acme=0
					sts		adcsrb,r16
ret
;==================================================================================
adc_read:
_adc_new:
					ldi		r16,(1<<aden)|(0<<adate)|(1<<adps2)|(1<<adps1)|(1<<adps0)
					sts		adcsra,r16

					lds		r16,adcsra
					ori		r16,(1<<adsc)	;запуск преобразования
					sts		adcsra,r16
_noready_adc:
					lds		r16,adcsra
					sbrs	r16,adif
					jmp		_noready_adc

					lds		r16,adcl
					lds		r17,adch
ret
;==================================================================================
;	выполнение суммы вход r17h r16l для усреднения
;	выход r18l, r19, r20h
;==================================================================================
adc_summ16:
					clr		r21
					add		r18,r16
					adc		r19,r17
					adc		r20,r21
ret
;==================================================================================
;	выполнение суммы вход r17 для усреднения
;	выход r18, r19
;==================================================================================
adc_summ:
					clr		r20
					add		r18,r17
					adc		r19,r20
ret
;==================================================================================
;	выполнение деления на 16 значени1 находящихсяв в r18, r19 для усреднения
;	выход r17
;==================================================================================
div_summ16:
					andi	r18,0xf0
					andi	r19,0x0f
					add		r18,r19
					swap	r18
					mov		r17,r18
ret
;==================================================================================
;	выполнение деления на 16 значени1 находящихсяв в r17 для десятичного преобразования
;	выход r17(целое) r16 (после запятой)
;==================================================================================
div_16:
					mov		r16,r17
					andi	r16,0x0f

					andi	r17,0xf0
					swap	r17
ret
;==================================================================================
;	выполнение деления на 4 значени1 находящихсяв в r17 для десятичного преобразования
;	выход r17(целое) r16 (после запятой)
;==================================================================================
div_4:
					mov		r16,r17
					andi	r16,0x0f

					andi	r17,0xf0
					swap	r17
ret

;==================================================================================
;перевод в 10 формат числа находящегося в r17	число не больше  99 
; выход r19(10) r20(1)
;==================================================================================
bcd_out:
					clc
					clr		r19	;10
					clr		r20	;1
;считаем количетво десятков
					ldi		r16,0x0a
_bcd_next10:
					sub		r17,r16
					brcs	_bcd_next1					
					inc		r19
					jmp		_bcd_next10
_bcd_next1:
					add		r17,r16
					clc
;считаем количетво десятков
					ldi		r16,0x01
_bcd_next1_0:
					sub		r17,r16
					brcs	_bcd_next1_e					
					inc		r20
					jmp		_bcd_next1_0
_bcd_next1_e:
ret
;==================================================================================
; измеряем напряжение на АКБ
;
;
;
;==================================================================================
batt_read_voltage:
					call	adc_init1
					
					clr		r18
					clr		r19
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ

					call	div_summ16
					sts		batt_adc,r17	;сохранили значение с АЦП

					
; расчитываем Vin = ( 5 * ADC ) / 64
					push	r0
					push	r1
					
					ldi		r16,0x05
					mul		r16,r17

					clr		r2			; здесь получаем то что буддет после зяпятой

					clc
					ror		r1			;/2
					ror		r0
					ror		r2

					clc
					ror		r1			;/2
					ror		r0
					ror		r2
										
					clc
					ror		r1			;/2
					ror		r0
					ror		r2

					clc
					ror		r1			;/2
					ror		r0
					ror		r2

					clc
					ror		r1			;/2
					ror		r0
					ror		r2

					clc
					ror		r1			;/2
					ror		r0
					ror		r2

					mov		r17,r0					
					mov		r16,r2

					pop		r1
					pop		r0

_batt_read_voltage_minus_100:
					cpi		r16,0x64		;>100
					brlo	_batt_read_voltage_no_minus_100
					subi	r16,0x64		; -100
					jmp		_batt_read_voltage_minus_100

_batt_read_voltage_no_minus_100:
					
;					call	div_16

					push	r16
					call	bcd_out

					ori		r19,0x30					
					ori		r20,0x30

					sts		batt_h10,r19
					sts		batt_h1,r20

					pop		r16
					mov		r17,r16
					call	bcd_out

					ori		r19,0x30					
					ori		r20,0x30

					sts		batt_l10,r19
					sts		batt_l1,r20

;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
					ldi		zl,low  (LCD_power_batt_voltage*2)
					ldi		zh,high (LCD_power_batt_voltage*2)
					call	lcd_write_string;вывод строки на экран
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
					lds		r17,batt_h10
					call	lcd_write_char
					lds		r17,batt_h1
					call	lcd_write_char
					ldi		r17,','
					call	lcd_write_char
					lds		r17,batt_l10
					call	lcd_write_char
					lds		r17,batt_l1
					call	lcd_write_char
					ldi		r17,'V'
					call	lcd_write_char
					ldi		r17,' '
					call	lcd_write_char

;выключаем ADC
					clr		r16
					sts		adcsra,r16

ret
;==================================================================================
; измеряем напряжение на АКБ во время теста батареии
;
;
;
;==================================================================================
batt_test_res:
					call	lcd_clr			;очистили ЖКИ

;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
					ldi		zl,low  (LCD_power_batt_test*2)
					ldi		zh,high (LCD_power_batt_test*2)
					call	lcd_write_string;вывод строки на экран
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

					lds		r16,batt_test_port
					ori		r16,(1 << batt_test)	; = 1	ON
					sts		batt_test_port,r16

					call	adc_init0
					
					call	batt_test_one_cycle
				
					ldi		r16,0x01
					call	delay_sec

					call	batt_test_one_cycle

					ldi		r16,0x02
					call	delay_sec

					call	batt_test_one_cycle

					ldi		r16,0x02
					call	delay_sec

					call	batt_test_one_cycle

					ldi		r16,0x02
					call	delay_sec

					call	batt_test_one_cycle

					ldi		r16,0x02
					call	delay_sec

					call	batt_test_one_cycle

					ldi		r16,0x02
					call	delay_sec

					call	batt_test_one_cycle


					lds		r16,batt_test_port
					andi	r16,~(1 << batt_test)	; = 0	OFF
					sts		batt_test_port,r16


;выключаем ADC
					clr		r16
					sts		adcsra,r16


ret
;==================================================================================
; проведение одного цикла тестирывания АКБ
;
;
;==================================================================================
batt_test_one_cycle:
					clr		r18
					clr		r19
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ
					call	adc_read
					call	adc_summ

					call	div_summ16
					;sts		batt_adc,r17	;сохранили значение с АЦП

					
; расчитываем Vin = ( 5 * ADC ) / 64
					push	r0
					push	r1
					
					ldi		r16,0x05
					mul		r16,r17

					clr		r2			; здесь получаем то что буддет после зяпятой

					clc
					ror		r1			;/2
					ror		r0
					ror		r2

					clc
					ror		r1			;/2
					ror		r0
					ror		r2
										
					clc
					ror		r1			;/2
					ror		r0
					ror		r2

					clc
					ror		r1			;/2
					ror		r0
					ror		r2

					clc
					ror		r1			;/2
					ror		r0
					ror		r2

					clc
					ror		r1			;/2
					ror		r0
					ror		r2

					mov		r17,r0					
					mov		r16,r2

					pop		r1
					pop		r0

_batt_test_voltage_minus_100:
					cpi		r16,0x64		;>100
					brlo	_batt_test_voltage_no_minus_100
					subi	r16,0x64		; -100
					jmp		_batt_test_voltage_minus_100

_batt_test_voltage_no_minus_100:
					
;					call	div_16

					push	r16
					call	bcd_out

					ori		r19,0x30					
					ori		r20,0x30

					sts		batt_test_h10,r19
					sts		batt_test_h1,r20

					pop		r16
					mov		r17,r16
					call	bcd_out

					ori		r19,0x30					
					ori		r20,0x30

					sts		batt_test_l10,r19
					sts		batt_test_l1,r20

;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
					ldi		zl,low  (LCD_power_batt_voltage*2)
					ldi		zh,high (LCD_power_batt_voltage*2)
					call	lcd_write_string;вывод строки на экран
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
					lds		r17,batt_test_h10
					call	lcd_write_char
					lds		r17,batt_test_h1
					call	lcd_write_char
					ldi		r17,','
					call	lcd_write_char
					lds		r17,batt_test_l10
					call	lcd_write_char
					lds		r17,batt_test_l1
					call	lcd_write_char
					ldi		r17,'V'
					call	lcd_write_char
					ldi		r17,' '
					call	lcd_write_char
ret

;==================================================================================
; Измерение входного напряжения
; пока только 48 вольт
; r19l-r22h сумма 16 значений для усреднения
; выход r16 - напряжение питания
;==================================================================================
pwr_in_adc:

;call	i2c_init

					lds		r16,vv_hard
					cpi		r16,VV_HARD_220
					breq	_pwr_in_adc_220

; 48v
					ldi		r16,8; counter
					
					clr 	r19
					clr		r20
					clr		r21
					;clr		r22

_pwr_in_adc1:
					push 	r16
					call	ads1100_read
					pop 	r16

					lds		r18, i2c_read		;high
					lds		r17, i2c_read+1		;low
					
					clr		r23
					add		r19,r17
					adc		r20,r18
					adc 	r21,r23
					;adc 	r22,r23
					
					push	r16
					push	r17
					call	delay20ms
					pop		r17
					pop		r16

					dec		r16
					brne	_pwr_in_adc1;=1 count
		
;/8 усредняем
					cli
					ror		r21
					ror		r20
					ror		r19

					ror		r21
					ror		r20
					ror		r19

					ror		r21
					ror		r20
					ror		r19
					sei

; vin= 94* COD16 / 32767(7fff)		
							
							
					ldi		r16,95
					mov		var10,r16

					ldi		r16,00
					mov		var11,r16


					mov		var20,r19
					mov		var21,r20

					call	mul16u

					ldi		r16,0xff
					mov		var20,r16

					ldi		r16,0x7f
					mov		var21,r16

					ldi		r16,0x00
					mov		var22,r16

					ldi		r16,0x00
					mov		var23,r16

					call	div32u		; делим на 7fff  r2 - входное напряжение !

					mov		r16,r2

					ret

_pwr_in_adc_220:
; 220v

					ldi		r16,220

					ret
;==================================================================================
; Измерение входного напряжения в буфер озу и вывод на lcd
;==================================================================================
lcd_pwr_in:

					call	pwr_in_adc		; преобразование входного напряжения питания R16

					ldi		zl,low(pwr_in_adc_bcd)
					ldi		zh,high(pwr_in_adc_bcd)

					mov		r17,r16
					call	hex_to_dec

					ldi		r16,0x30
					add		r18,r16
					add		r19,r16
					add		r20,r16

					cpi		r18,0x30
					breq	_lcd_pwr_in_2bcd


					sts		pwr_in_adc_bcd+0,r18
					sts		pwr_in_adc_bcd+1,r19
					sts		pwr_in_adc_bcd+2,r20

					mov		r17,r18
					call	lcd_write_char
					mov		r17,r19
					call	lcd_write_char
					mov		r17,r20
					call	lcd_write_char

					ldi		r17,' '
					call	lcd_write_char
					ldi		r17,'V'
					call	lcd_write_char

					ret
_lcd_pwr_in_2bcd:
					ldi		r18,' '
					sts		pwr_in_adc_bcd+0,r18
					sts		pwr_in_adc_bcd+1,r19
					sts		pwr_in_adc_bcd+2,r20

					mov		r17,r18
					call	lcd_write_char
					mov		r17,r19
					call	lcd_write_char
					mov		r17,r20
					call	lcd_write_char

					ldi		r17,' '
					call	lcd_write_char
					ldi		r17,'V'
					call	lcd_write_char

					ret
;==================================================================================
; Чтение значений с датчика тока
; r18l r19h
;==================================================================================
dat_i_adc:
				call	adc_init2

				clr 	r18
				clr		r19
				clr		r20

				ldi		r16,16
_dat_i_adc:
				push 	r16

				call	adc_read
				call	adc_summ16;вход r17h r16l    выход r18l, r19, r20h

				pop		r16
				dec		r16
				brne	_dat_i_adc

				cli
				ror		r20 			; усреднение деление на 16
				ror		r19
				ror		r18

				ror		r20
				ror		r19
				ror		r18

				ror		r20
				ror		r19
				ror		r18

				ror		r20
				ror		r19
				ror		r18
				sei

				andi	r19,0x03		; убираем все лишнии биты которые могли появиться после сдвига

				ret

;==================================================================================
; Калибровка датчика тока
; 
;==================================================================================
dat_i_calibrate:
				ldi 	zl,low (rele_load_position)	; т EEPROM
				ldi 	zh,high (rele_load_position)
				;ldi		r16,RELE_POS_OFF
				call	eeprom_read_byte
				push	r16

				call	rele_set_off

				ldi		r16,0x03	;пауза 1.5 сек
				call	delay_sec

				call	dat_i_adc

				push 	r19

				mov 	r16,r18					; сохранем в еерпом калибровачную константу
				ldi		zl,low(dat_i_zero)
				ldi		zh,high(dat_i_zero)		;low
				call	eeprom_write_byte

				pop		r19
				mov 	r16,r19
				ldi		zl,low(dat_i_zero)
				ldi		zh,high(dat_i_zero)
				adiw	z,1						;high
				call	eeprom_write_byte

; выставляем предыдущее положение реле
				pop		r16

				cpi		r16,RELE_POS_OFF
				breq	_dat_i_c_rele_off

				call	rele_set_on

_dat_i_c_rele_off:
				ret

;==================================================================================
; расчет тока потребления нагрузкой
; 
;==================================================================================
math_ip_load:
; смотрим если реле выключено то потребьеление 0!
				ldi		zl,low(rele_load_position)
				ldi		zh,high(rele_load_position)		;low
				call	eeprom_read_byte

				cpi		r16,RELE_POS_ON
				breq	_math_ip_load1

				clr		r16
				sts		load_p+0,r16
				sts		load_p+1,r16
				sts		load_i,r16

				ldi		r16,0x30
				ldi		r17,' '

				sts		bcd_load_i+0,r17
				sts		bcd_load_i+1,r16
				sts		bcd_load_i+2,r16

				sts		bcd_load_p+0,r17
				sts		bcd_load_p+1,r17
				sts		bcd_load_p+2,r17
				sts		bcd_load_p+3,r16
				
				ret

_math_ip_load1:
				ldi		zl,low(dat_i_zero)
				ldi		zh,high(dat_i_zero)		;low
				call	eeprom_read_byte

				push 	r16

				ldi		zl,low(dat_i_zero)
				ldi		zh,high(dat_i_zero)
				adiw	z,1						;high
				call	eeprom_read_byte

				push 	r16

				call	dat_i_adc		; r18l r19h


				pop  	zh ;high	calibrate constant
				pop		zl ;low

				sub		zl,r18
				sbc		zh,r19
				
				brcc	_math_ip_l1		; c=0, Const_calib >= i_dat

				com		zl
				com		zh
				adiw	zl,1			; изменяем знак отрицательное число переводим в положительное
_math_ip_l1:

; I load= 50* ADC-COD10 / 240		; и * на 10 для переноса запятой Потом учесть !
							
				ldi		r16,0xf4
				mov		var10,r16

				ldi		r16,0x01	
				mov		var11,r16	; 500


				mov		var20,zl
				mov		var21,zh

				call	mul16u

				ldi		r16,0xf0;e8
				mov		var20,r16

				ldi		r16,0x00
				mov		var21,r16

				ldi		r16,0x00
				mov		var22,r16

				ldi		r16,0x00
				mov		var23,r16

				call	div32u			; делим на 232  var10 - ток потребления

				mov		r16,var10

				cpi		r16,5
				brsh	_math_ip_l2		; >= 0.5 А значит 0 А ток потребления !

				clr		r16
				jmp		_math_ip_l3
_math_ip_l2:
				subi	r16,5			; -0.5 А тк погрешность 
_math_ip_l3:
				sts		load_i,r16

				cpi		r16,5			; < 0.5 А
				brlo	_math_ip_l4		; < 0.5

; P load = Uin * load_i / 10;
				call	pwr_in_adc 		; Измерение входного напряжения выход r16 - напряжение питания

				mov		var10,r16

				ldi		r16,0x00	
				mov		var11,r16

				lds		r16,load_i

				mov		var20,r16
				clr		var21

				call	mul16u

				ldi		r16,10
				mov		var20,r16

				ldi		r16,0x00
				mov		var21,r16

				ldi		r16,0x00
				mov		var22,r16

				ldi		r16,0x00
				mov		var23,r16

				call	div32u		; делим, var10-11 - P потребления

				mov		r16,var10
				sts		load_p+0,r16

				mov		r16,var11
				sts		load_p+1,r16
			
				jmp		_math_ip_l5

_math_ip_l4:
				clr		r16
				sts		load_p+0,r16
				sts		load_p+1,r16
				
				mov		var10,r16
				mov		var11,r16

_math_ip_l5:
				lds		var0,load_i

				ldi		yl,low(bcd_load_i)
				ldi		yh,high(bcd_load_i)

				ldi		len,3

				call	mk_decu8

; ставим 0 перед запятой если нужно
				
				lds		r16,bcd_load_i+1
				cpi		r16,' '
				brne	_math_ip_l6

				ldi		r16,0x30	; ставим 0 перед запятой
				sts		bcd_load_i+1,r16


_math_ip_l6:
				mov		var0,var10
				mov		var1,var11

				ldi		yl,low(bcd_load_p)
				ldi		yh,high(bcd_load_p)

				ldi		len,4

				call	mk_decu16
ret
;==================================================================================
; вывод на жки тока потребления и мощности
; 
;==================================================================================
lcd_ip_load:

					call	lcd_clr

					ldi		zl,low  (LCD_load_i_out*2)
					ldi		zh,high (LCD_load_i_out*2)
					call	lcd_write_string		;вывод строки на экран


					lds		r17,bcd_load_i+0
					call	lcd_write_char;in R17

					lds		r17,bcd_load_i+1
					call	lcd_write_char;in R17

					ldi		r17,','
					call	lcd_write_char;in R17

					lds		r17,bcd_load_i+2
					call	lcd_write_char;in R17

					ldi		r17,' '
					call	lcd_write_char;in R17

					ldi		r17,'A'
					call	lcd_write_char;in R17




					ldi		zl,low  (LCD_load_p_out*2)
					ldi		zh,high (LCD_load_p_out*2)
					call	lcd_write_string		;вывод строки на экран


					lds		r17,bcd_load_p+0
					call	lcd_write_char;in R17

					lds		r17,bcd_load_p+1
					call	lcd_write_char;in R17

					lds		r17,bcd_load_p+2
					call	lcd_write_char;in R17

					lds		r17,bcd_load_p+3
					call	lcd_write_char;in R17


					ldi		r17,' '
					call	lcd_write_char;in R17

					ldi		r17,'W'
					call	lcd_write_char;in R17


					ldi		r16,0x03
					call	delay_sec


ret
