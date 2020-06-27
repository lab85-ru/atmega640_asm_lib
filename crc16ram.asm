;================================================================================================================
;	crc 16 ram
;	x - start adr
;	y - len
//Name : "CRC 16"
//Width : 16
//Poly : 8005
//Init : 0000
//RefIn : True
//RefOut : True
//XorOut : 0000
//Check : BB3D
;================================================================================================================
.def		count8	=	r17						;	счетчик числа сдвигов 8 раз		

.def		crcl	=	r18						; 	подсчитываемая контрольная сумма
.def		crch	=	r19

.def		polyl	=	r20						;	регистры содержащие полином
.def		polyh	=	r21

.equ		POLY_CRC	=	0xA001				;	сам полином для подсчета (зеркальный помином !!! 8005)

;unsigned int ms_crc16(_U8 *msg_p, _U8 length)
;{
;    unsigned int crc;
;    _U8  msg_ptr, cnt;
crc16ram:
;    crc = 0x0;									//	init
				clr		crcl
				clr		crch

				ldi		polyl,low(POLY_CRC)
				ldi		polyh,high(POLY_CRC)


;    for (msg_ptr = 0; msg_ptr < length; msg_ptr++)
;    {
;        crc = crc ^ msg_p[msg_ptr];
_crc16ram0:				
				ld		r16,x+
				eor		crcl,r16
				
				sbiw	yl,1		

;        for (cnt = 0; cnt < 8; cnt++)
				clr		count8
_crc16ram_count8:						
;        {
;            if ( crc & 0x0001 == 1 )
				mov		r16,crcl
				andi	r16,0x01
				tst		r16
				
				breq	_crc16ram_zero	
;            {
;                crc >>= 1;
				lsr		crch
				ror		crcl
;                crc = crc ^ 0xa001;             // Reversed 0x8005 polynom
				eor		crcl,polyl
				eor		crch,polyh

				rjmp 	_crc16ram_q1
;            } else
_crc16ram_zero:
;                crc >>= 1;
				lsr		crch
				ror		crcl
_crc16ram_q1:
				inc		count8
				cpi		count8,0x08
				brne 	_crc16ram_count8


				cpi		yh,0
				brne	_crc16ram0
				cpi		yl,0
				brne	_crc16ram0


				mov		r0,crcl
				mov		r1,crch

				ret

;        }
;    }

;	crc = 0x0 ^ crc;							//	init out

;    return crc;
;}

;================================================================================================================
