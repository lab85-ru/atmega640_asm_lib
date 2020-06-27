;================================================================================================================
;	������������ ����������� ������ �� RAM -> EEPROM
;										Y		  Z
;	r19 ���� ������ ������ (�������� ������ � �������)	
;================================================================================================================
copy_ram_eeprom:
					ldi			r18,0x00			; ������� ���������� ������������ ����

_copy_r_e0:
					cp			r18,r19
					breq 		_copy_r_e_end

					ld			r16,y+
					call		eeprom_write_byte	; ���������
					adiw		zl,0x01				; z+1

					inc			r18					; ������� +1

					jmp 		_copy_r_e0
_copy_r_e_end:
					ret
;================================================================================================================
