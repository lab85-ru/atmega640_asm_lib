.cseg
ow_path:		.db 	ds18s20_init,ds18s20_w,0xcc,ds18s20_w,0x44,ds18s20_delay,ds18s20_init,ds18s20_w,0xcc,ds18s20_w,0xbe,ds18s20_r,ds18s20_r,ds18s20_r,ds18s20_r,ds18s20_r,ds18s20_r,ds18s20_r,ds18s20_r,ds18s20_r
ow_len:			.db		0x14;len


; ������ 3 ��������� �� ������������
INT_TIMER3_OC3A:
				push	r16
				in		r16,sreg
				push	r16


				lds		r16,t_port_in			; ��������� �������� �����
				;andi	r16,(1<<t_pin)
				and		r16,t_pin1
				sts		ow_pin,r16				; ��������� �������� �������� �����

				lds		r16,ow_state			; ow_state++
				inc		r16
				sts		ow_state,r16

; ���������� ������� � ������������� ������ ����� ��������� ����� ��������
				lds		r16,GTCCR
				ori 	r16,(1<<TSM)|(1<<PSRSYNC)
				out 	GTCCR,r16

				ldi		r16,(1<<WGM32)					; timer stop
				sts		TCCR3B,r16

				pop		r16
				out		sreg,r16
				pop		r16
				
				reti

;=======================================================================================
; ������� ������� ��������� ������ � ��������
;=======================================================================================
ow_automat:
; ��������� �������� ���������� ?
				cli							; �� ������ ������
				lds		r16,ow_state
				lds		r17,ow_state_h
				sei
				
				cp		r16,r17
				brne	_ow_automat_go
				
				ret		; ��������� �� ���������� ������� �� ������ ������������	

_ow_automat_go:
; ��������� ��� ������� ������� ����������
				ldi		zl,low(ow_len*2)
				ldi		zh,high(ow_len*2)

				lpm		r16,z

				lds		r17,ow_offset

				cp		r16,r17
				brne	_ow_automat_go1

				ldi		r16,0xff			; ��� ��� ���������� �� ������ � ����������� ���� �����
				sts		ow_state,r16
				sts		ow_state_h,r16
				
				ldi		r16,0xaa			; ��������� ��������� ����������� ������� !!!
				sts		ow_status,r16
				ret

_ow_automat_go1:
; ����� ���� � path
				ldi		zl,low(ow_path*2)
				ldi		zh,high(ow_path*2)

; x = adr( path	+  offset )
				lds		r16,ow_offset
				clr 	r17
				add		zl,r16
				adc		zh,r17

				lpm		r17,z

; ����� ���������� ��������� ��������
				cpi		r17,ds18s20_init
				breq	_ds18s20_init
				cpi		r17,ds18s20_w
				breq	_ds18s20_w
				cpi		r17,ds18s20_r
				breq	_ds18s20_r
				cpi		r17,ds18s20_delay
				breq	_ds18s20_delay
; �������� ��������� ������������� ������ � ������ � �������
				rjmp	_ds18s20_error


;------------------------
_ds18s20_init:	call	ow_init
				ret
_ds18s20_w:		call	ow_w
				ret
_ds18s20_r:		call	ow_r
				ret
_ds18s20_delay:	call	ow_delay
				ret
_ds18s20_error:	call	ow_error
				ret
;=======================================================================================
; ��������� ������������� ������� + ����������� �����������
;=======================================================================================
ow_init:
				lds 	r16,ow_state

				cpi		r16,0x00
				breq	_ow_init0
				cpi		r16,0x01
				breq	_ow_init1
				cpi		r16,0x02
				breq	_ow_init2
				call	ow_error
				ret

_ow_init0:		call	ow_init_st0
				ret	
_ow_init1:		call	ow_init_st1
				ret	
_ow_init2:		call	ow_init_st2
				ret	

;++++++++++++++++++++++++++++
; ow_init_st0
;++++++++++++++++++++++++++++
ow_init_st0:
				;sbi		t_ddr,t_pin_power				; ����� ������!
				lds		r16,t_ddr
				;ori		r16,(1<<t_pin_power)
				or		r16,t_pin_power1
				sts		t_ddr,r16

				;sbi		t_port_out,t_pin_power			; =1 ���������� ������ !!!
				lds		r16,t_port_out
				;ori		r16,(1<<t_pin_power)
				or		r16,t_pin_power1
				sts		t_port_out,r16

				;sbi		t_ddr,t_pin						; ����������� ���� �� ����� out
				lds		r16,t_ddr
				;ori		r16,(1<<t_pin)
				or		r16,t_pin1
				sts		t_ddr,r16

				;cbi		t_port_out,t_pin				; pin = 0
				lds		r16,t_port_out
				;andi	r16,~(1<<t_pin)
				and		r16,t_pin0
				sts		t_port_out,r16

				ldi		r16,0x01			; ������� ���������: ������ ��������� �����������
				sts		ow_status,r16
				
				clr		r16					; ����������������� �������� ��������
				sts		ow_state,r16
				sts		ow_state_h,r16

; ����������� ������ �� �������� 600 ���
;				ldi		r17,(1<<WGM32);|(1<<CS32)|(1<<CS31)|(1<<CS30)	; timer stop
;				ldi		r17,(1<<WGM32)|(1<<CS30)						; /1
;				ldi		r17,(1<<WGM32)|(1<<CS31)						; /8
;				ldi		r17,(1<<WGM32)|(1<<CS31)|(1<<CS30)				; /64
				ldi		r17,(1<<WGM32)|(1<<CS32)						; /256
;				ldi		r17,(1<<WGM32)|(1<<CS32)|(1<<CS30)				; /1024

				ldi		zl,0x11
				ldi		zh,0

				call 	timer3_init
ret
;++++++++++++++++++++++++++++
; ow_init_st1
;++++++++++++++++++++++++++++
ow_init_st1:
				;cbi		t_ddr,t_pin			; ����������� ���� �� ����
				lds		r16,t_ddr
				;andi	r16,~(1<<t_pin)
				and		r16,t_pin0
				sts		t_ddr,r16

				lds		r16,ow_state		; ow_state_h = ow_state
				sts		ow_state_h,r16
				
; ����������� ������ �� �������� 100 ���
;				ldi		r17,(1<<WGM32);|(1<<CS32)|(1<<CS31)|(1<<CS30)	; timer stop
;				ldi		r17,(1<<WGM32)|(1<<CS30)						; /1
;				ldi		r17,(1<<WGM32)|(1<<CS31)						; /8
				ldi		r17,(1<<WGM32)|(1<<CS31)|(1<<CS30)				; /64
;				ldi		r17,(1<<WGM32)|(1<<CS32)						; /256
;				ldi		r17,(1<<WGM32)|(1<<CS32)|(1<<CS30)				; /1024

				ldi		zl,0x0b
				ldi		zh,0

				call 	timer3_init
				
ret
;++++++++++++++++++++++++++++
; ow_init_st2
;++++++++++++++++++++++++++++
ow_init_st2:
				lds		r16,ow_pin					; ��������� �������� �����
				tst		r16
				breq	_ow_init_st2_datchik_ok		; ������ �������
				; ������ �� �������, ������ ���������
				ldi		r16,0xee
				sts		ow_status,r16		; ������ ������ ���������� ������ � ����� !

; ����������� ������ �� STOP
;				ldi		r17,(1<<WGM32);|(1<<CS32)|(1<<CS31)|(1<<CS30)	; timer stop
;				ldi		zl,0x00
;				ldi		zh,0
;				call 	timer3_init
				ret

_ow_init_st2_datchik_ok:	; ������ �������

				; ow_state = ff
				ldi		r16,0xff
				sts		ow_state,r16
				sts		ow_state_h,r16

				lds		r16,ow_offset		; ow_offset++
				inc 	r16
				sts		ow_offset,r16
; �� ������ ������ ������� � �������� ��������
				ldi 	r16,0x01
				sts 	ow_bit_counter,r16		; bit_counter = 0x01
				

; ����������� ������ �� �������� 300 ���
;				ldi		r17,(1<<WGM32);|(1<<CS32)|(1<<CS31)|(1<<CS30)	; timer stop
;				ldi		r17,(1<<WGM32)|(1<<CS30)						; /1
;				ldi		r17,(1<<WGM32)|(1<<CS31)						; /8
;				ldi		r17,(1<<WGM32)|(1<<CS31)|(1<<CS30)				; /64
				ldi		r17,(1<<WGM32)|(1<<CS32)						; /256
;				ldi		r17,(1<<WGM32)|(1<<CS32)|(1<<CS30)				; /1024

				ldi		zl,0x08
				ldi		zh,0

				call 	timer3_init
				
ret
;=============================================================================
; ������ ��� ������ �������� !!! ���������� ���������
;=============================================================================
ow_error:
				ldi		r16,0xe1
				sts		ow_status,r16		; ������ ������ ���������� ������ � ����� !

; ����������� ������ �� STOP
				ldi		r17,(1<<WGM32);|(1<<CS32)|(1<<CS31)|(1<<CS30)	; timer stop
;				ldi		r17,(1<<WGM32)|(1<<CS30)						; /1
;				ldi		r17,(1<<WGM32)|(1<<CS31)						; /8
;				ldi		r17,(1<<WGM32)|(1<<CS31)|(1<<CS30)				; /64
;				ldi		r17,(1<<WGM32)|(1<<CS32)						; /256
;				ldi		r17,(1<<WGM32)|(1<<CS32)|(1<<CS30)				; /1024

				ldi		zl,0x00
				ldi		zh,0

				call 	timer3_init

ret
;=============================================================================
; ������ ������ ����� � ������
;=============================================================================
ow_w:
				lds 	r16,ow_state

				cpi		r16,0x00
				breq	_ow_write0
				cpi		r16,0x01
				breq	_ow_write1
				call	ow_error
				ret

_ow_write0:		call	ow_write_st0
				ret	
_ow_write1:		call	ow_write_st1
				ret	
;++++++++++++++++++++++++++++
; ow_write_st0
;++++++++++++++++++++++++++++
ow_write_st0:
; ����� ���� � path
				ldi		zl,low(ow_path*2)
				ldi		zh,high(ow_path*2)

; x = adr( path	+  offset )
				lds		r16,ow_offset
				clr 	r17
				add		zl,r16
				adc		zh,r17
; +1 �������������� �������� ��� ��� ������ ���� ������� ������ ������ !!!
				ldi		r16,0x01

				add		zl,r16
				adc		zh,r17

				lpm		r17,z				; ������� ���� ������� ���� ��������

;				sts 	ow_temp,r17			; ��������� ������� ������������ ����

				lds 	r16,ow_bit_counter
				
				and		r16,r17

				sts 	ow_bit_out,r16			; ��������� �������� ������� �������



				cli

				;sbi		t_ddr,t_pin			; ����������� ���� �� �����
				lds		r16,t_ddr
				;ori		r16,(1<<t_pin)
				or		r16,t_pin1
				sts		t_ddr,r16

				;cbi		t_port_out,t_pin		; pin = 0
				lds		r16,t_port_out
				;andi	r16,~(1<<t_pin)
				and 	r16,t_pin0
				sts		t_port_out,r16


; �������� 5 ��� 
				call	delay_5mks
; ������� ����������� ���
				lds		r16,ow_bit_out
				tst		r16
				breq	_ow_write_st1_00

				;sbi		t_port_out,t_pin		; pin = 1
				lds		r16,t_port_out
				;ori		r16,(1<<t_pin)
				or		r16,t_pin1
				sts		t_port_out,r16
				
				rjmp 	_ow_write_st1_e

_ow_write_st1_00:
				;cbi		t_port_out,t_pin		; pin = 0
				lds		r16,t_port_out
				;andi	r16,~(1<<t_pin)
				and		r16,t_pin0
				sts		t_port_out,r16


_ow_write_st1_e:
				sei

; ����������� ������ �� �������� 120 ���
;				ldi		r17,(1<<WGM32);|(1<<CS32)|(1<<CS31)|(1<<CS30)	; timer stop
;				ldi		r17,(1<<WGM32)|(1<<CS30)						; /1
;				ldi		r17,(1<<WGM32)|(1<<CS31)						; /8
				ldi		r17,(1<<WGM32)|(1<<CS31)|(1<<CS30)				; /64
;				ldi		r17,(1<<WGM32)|(1<<CS32)						; /256
;				ldi		r17,(1<<WGM32)|(1<<CS32)|(1<<CS30)				; /1024

				ldi		zl,0x0f
				ldi		zh,0

				call 	timer3_init

				lds		r16,ow_state			; ow_state_h = ow_state
				sts		ow_state_h,r16
ret
;++++++++++++++++++++++++++++
; ow_write_st1
;++++++++++++++++++++++++++++
ow_write_st1:
				;sbi		t_port_out,t_pin		; pin = 1
				lds		r16,t_port_out
				;ori		r16,(1<<t_pin)
				or		r16,t_pin1
				sts		t_port_out,r16

; ����������� ������ �� �������� 100 ���
;				ldi		r17,(1<<WGM32);|(1<<CS32)|(1<<CS31)|(1<<CS30)	; timer stop
;				ldi		r17,(1<<WGM32)|(1<<CS30)						; /1
				ldi		r17,(1<<WGM32)|(1<<CS31)						; /8
;				ldi		r17,(1<<WGM32)|(1<<CS31)|(1<<CS30)				; /64
;				ldi		r17,(1<<WGM32)|(1<<CS32)						; /256
;				ldi		r17,(1<<WGM32)|(1<<CS32)|(1<<CS30)				; /1024

				ldi		zl,0x64
				ldi		zh,0

				call 	timer3_init

				lds 	r16,ow_bit_counter

				cpi		r16,0x80
				breq	_ow_write_st2_next_command

				lsl		r16						; bit_counter << 1
				sts		ow_bit_counter,r16

				ldi 	r16,0xff
				sts		ow_state,r16			; ow_state = ff
				sts		ow_state_h,r16			; ow_state_h = ff

				ret

_ow_write_st2_next_command:
				ldi		r16,0x01				; bit_counter = 1
				sts		ow_bit_counter,r16

				ldi 	r16,0xff
				sts		ow_state,r16			; ow_state = ff
				sts		ow_state_h,r16			; ow_state_h = ff

				lds 	r16,ow_offset
				inc 	r16						; ow_offset + 2
				inc 	r16
				sts 	ow_offset,r16

;				lds 	r16,ow_temp				; ����� ������� ������������ ����
				
;				cpi		r16,DS18S20_CMD_CONV_TEMPER		; ���� ������� �������������� ����������� ?
;				breq	_ow_write_st2_convtemp
;				ret	

;_ow_write_st2_convtemp:
;				cbi		t_port_out,t_pin_power			; ������ ��������� ������� �� ����� �������������� �����������
ret


;=============================================================================
; �������� 5 ���
;=============================================================================
delay_5mks:
; �������� 5 ��� 
				clr		r16					; 1

_delay_5mks_count:
				cpi		r16,0x08			; 1
				breq	_delay_5mks_e		; 1/2

				inc		r16					; 1

				rjmp 	_delay_5mks_count	; 2
_delay_5mks_e:
ret
;=============================================================================
; �������� �� ������������� �����������
;=============================================================================
ow_delay:
				;sbi		t_ddr,t_pin			; ����������� ���� �� �����
				lds		r16,t_ddr
				;ori		r16,(1<<t_pin)
				or		r16,t_pin1
				sts		t_ddr,r16

				;sbi		t_port_out,t_pin	; pin = 1
				lds		r16,t_port_out
				;ori		r16,(1<<t_pin)
				or		r16,t_pin1
				sts		t_port_out,r16

				;cbi		t_port_out,t_pin_power			; ������ ��������� ������� �� ����� �������������� �����������
				lds		r16,t_port_out
				;andi	r16,~(1<<t_pin_power)
				and		r16,t_pin_power0
				sts		t_port_out,r16

; ����������� ������ �� �������� 750 ��
;				ldi		r17,(1<<WGM32);|(1<<CS32)|(1<<CS31)|(1<<CS30)	; timer stop
;				ldi		r17,(1<<WGM32)|(1<<CS30)						; /1
;				ldi		r17,(1<<WGM32)|(1<<CS31)						; /8
;				ldi		r17,(1<<WGM32)|(1<<CS31)|(1<<CS30)				; /64
;				ldi		r17,(1<<WGM32)|(1<<CS32)						; /256
				ldi		r17,(1<<WGM32)|(1<<CS32)|(1<<CS30)				; /1024

				ldi		zl,0xed
				ldi		zh,0x14

				call 	timer3_init

				ldi		r16,0x01				; bit_counter = 1
				sts		ow_bit_counter,r16

				ldi 	r16,0xff
				sts		ow_state,r16			; ow_state = ff
				sts		ow_state_h,r16			; ow_state = ff

				lds 	r16,ow_offset
				inc 	r16						; ow_offset++
				sts 	ow_offset,r16

				clr		r16
				sts		ow_read,r16				; �������� �����, ���������� ��� ����� �����
				sts		ow_read_n,r16			; �������� ������� ����� �������� ����

ret
;=============================================================================
; ������ ������ ����� �� �������
;=============================================================================
ow_r:
				cli

				;sbi		t_ddr,t_pin			; ����������� ���� �� �����
				lds		r16,t_ddr
				;ori		r16,(1<<t_pin)
				or		r16,t_pin1
				sts		t_ddr,r16

				;cbi		t_port_out,t_pin		; pin = 0
				lds		r16,t_port_out
				;andi	r16,~(1<<t_pin)
				and		r16,t_pin0
				sts		t_port_out,r16

; �������� 5 ��� 
				call	delay_5mks

				;cbi		t_ddr,t_pin			; ����������� ���� �� ����
				lds		r16,t_ddr
				;andi	r16,~(1<<t_pin)
				and		r16,t_pin0
				sts		t_ddr,r16

				;sbi		t_port_out,t_pin		; pin = 1
				lds		r16,t_port_out
				;andi	r16,~(1<<t_pin)
				and		r16,t_pin0
				sts		t_port_out,r16

; �������� 5 ��� 
				call	delay_5mks
			
				;in		r16,t_port_in			; ��������� �������� �����
				lds		r16,t_port_in			; ��������� �������� �����

				;andi	r16,(1<<t_pin)
				and		r16,t_pin1
;				sts		ow_pin,r16				; ��������� �������� �������� �����

				sei

;				lds		r16,ow_pin
				tst		r16
				breq	_ow_r_0			; =0 �������

				lds		r16,ow_read
				lds		r17,ow_bit_counter
				or		r16,r17					; ow_read |= ow_bit_counter
				sts		ow_read,r16
_ow_r_0:
; ����������� ������ �� �������� 100 ���
;				ldi		r17,(1<<WGM32);|(1<<CS32)|(1<<CS31)|(1<<CS30)	; timer stop
;				ldi		r17,(1<<WGM32)|(1<<CS30)						; /1
;				ldi		r17,(1<<WGM32)|(1<<CS31)						; /8
				ldi		r17,(1<<WGM32)|(1<<CS31)|(1<<CS30)				; /64
;				ldi		r17,(1<<WGM32)|(1<<CS32)						; /256
;				ldi		r17,(1<<WGM32)|(1<<CS32)|(1<<CS30)				; /1024

				ldi		zl,0x0c
				ldi		zh,0

				call 	timer3_init
				
				lds		r16,ow_bit_counter

				cpi		r16,0x80
				breq	_ow_r_e			; ��� ���� ������� � ������ �����, ��������� ����

				lsl		r16
				sts 	ow_bit_counter,r16		; ow_bit_counter << 1

				ldi		r16,0xff
				sts		ow_state,r16			; ow_state = ff
				sts		ow_state_h,r16			; ow_state_h = ff
				
				ret				
_ow_r_e:
				ldi		r16,0x01
				sts 	ow_bit_counter,r16		; ow_bit_counter = 1
				
				ldi		r16,0xff
				sts		ow_state,r16			; ow_state = ff
				sts		ow_state_h,r16			; ow_state_h = ff


				lds		r16,ow_offset
				inc		r16
				sts 	ow_offset,r16			; ow_offset++

				ldi		zl,low(ow_read_buf)	
				ldi		zh,high(ow_read_buf)

				lds		r16,ow_read_n
				clr 	r17

				add		zl,r16
				adc		zh,r17					; Z = adr + offset

				lds		r16,ow_read			

				st		z,r16					; ��������� � ������� ������� ����

				clr		r16
				sts		ow_read,r16				; �������� ����� ��� ��������� ����

				lds		r16,ow_read_n			; ow_read_n ++
				inc		r16
				sts		ow_read_n,r16

				ret


;=============================================================================
; ��������� ������� �� �������� �� ����������
;
; z   - 16 ��������� ��������,  
; r17 - ��������
;=============================================================================
timer3_init:
; ����������� ������ �� �������� 600 ���
; ���������� ������� � ������������� ������ ����� ��������� ����� ��������
				in		r16,GTCCR
				ori 	r16,(1<<TSM)|(1<<PSRSYNC)
				out 	GTCCR,r16
; ����� ��� ��� �������� ������ !!!!
; ������� ����� ��������
;				ldi		r16,0x00
;				sts		TCCR3A,r16

;				ldi		r17,(1<<WGM32);|(1<<CS32)|(1<<CS31)|(1<<CS30)	; timer stop
;				ldi		r17,(1<<WGM32)|(1<<CS30)						; /1
;				ldi		r17,(1<<WGM32)|(1<<CS31)						; /8
;				ldi		r17,(1<<WGM32)|(1<<CS31)|(1<<CS30)				; /64
;				ldi		r17,(1<<WGM32)|(1<<CS32)						; /256
;				ldi		r17,(1<<WGM32)|(1<<CS32)|(1<<CS30)				; /1024
				sts		TCCR3B,r17

				ldi		r16,0x00
				sts 	TCCR3C,r16

; ����� ��� ��� �������� ������ !!!!
; �������� ������� �������
				ldi		r16,0x00
				sts		TCNT3H,r16
				sts		TCNT3L,r16

; ��������� �������� ��� ���������
				sts 	OCR3AH,zh		; ������� �������� ������ ���� ������ ����� !!!
				sts 	OCR3AL,zl

; ��������� ������� ����� ������� � ���������
				in		r16,GTCCR
				andi 	r16,~((1<<TSM)|(1<<PSRSYNC))
				out 	GTCCR,r16
				ret
;================================================================================================================
//////////////////////////////////////////////////////////////////////////////////////////
;t_start		; ������ ��������� �����������
//////////////////////////////////////////////////////////////////////////////////////////
t_start:

				lds		r16,TIMSK3
				ori		r16,(1<<OCIE3A)	; ����������� ���������� �� ���������� �3
				sts 	TIMSK3,r16


; ������� ����� ��������
				ldi		r16,0x00
				sts		TCCR3A,r16
; �������� ������� �������
				ldi		r16,0x00
				sts		TCNT3L,r16
				sts		TCNT3H,r16

;				ldi		r17,(1<<WGM32);|(1<<CS32)|(1<<CS31)|(1<<CS30)	; timer stop
;				ldi		r17,(1<<WGM32)|(1<<CS30)						; /1
;				ldi		r17,(1<<WGM32)|(1<<CS31)						; /8
;				ldi		r17,(1<<WGM32)|(1<<CS31)|(1<<CS30)				; /64
				ldi		r17,(1<<WGM32)|(1<<CS32)						; /256
;				ldi		r17,(1<<WGM32)|(1<<CS32)|(1<<CS30)				; /1024

				ldi		zl,0x10
				ldi		zh,0

				call 	timer3_init

; ������ ��������� �������� ��� ��������
				ldi 	r16,0x00
				sts		ow_state,r16
				sts		ow_read_n,r16
				sts		ow_offset,r16

;				dec		r16					; r16=ff ���� ���������� �������
				ldi		r16,0xff			; r16=ff ���� ���������� �������
				sts		ow_state_h,r16

				ldi		r17,0x01
				sts 	ow_status,r17
				sts		ow_bit_counter,r17

ret
;================================================================================================================
