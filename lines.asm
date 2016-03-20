; #########################################################################
;
;   lines.asm - Assembly file for EECS205 Assignment 2
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc

.DATA
;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943           	;;  PI / 2
PI =  205887	                ;;  PI 
TWO_PI	= 411774                ;;  2 * PI 
PI_INC_RECIP =  5340353        	;;  256 / PI   (use this to find the table entry for a given angle
	                        ;;              it is easier to use than divison would be)
ROW_WIDTH = 640			;; int representation of width of row

i DWORD ?
fixed_inc DWORD ?
fixed_j DWORD ?



	;; If you need to, you can place global variables here
	
.CODE
	
FixedSin PROC USES ebx ecx angle:FXPT
LOCAL resultAngle:FXPT
	;; basically produce a resultAngle that is between 0 and pi/2
	;; then perform any necessary transformations
	mov eax, angle
	mov resultAngle, eax

	cmp resultAngle, 0
	jge main

	add resultAngle, TWO_PI
	invoke FixedSin, resultAngle
	ret

main:
	cmp resultAngle, PI_HALF
	jl lt_pi_half
	
	cmp resultAngle, PI_HALF 		;; exactly pi_half
	je pi_half

	cmp resultAngle, PI
	jl pi_half_to_pi

	mov eax, PI				;; greater than pi, so calculate negative
	sub resultAngle, eax
	invoke FixedSin, resultAngle
	mov ecx, 0	
	sub ecx, eax				;; subtract from 0 to get negative
	mov eax, ecx
	ret

lt_pi_half:					;; anything 0 to pi/2
	mov ecx, PI_INC_RECIP
	imul ecx
	movzx eax, WORD PTR [SINTAB + 2*edx]	
	ret

pi_half:					;; a value close to 0
	mov eax, 1
	shl eax, 16
	ret

pi_half_to_pi:
	mov eax, PI
	sub eax, resultAngle
	invoke FixedSin, eax
	ret
	
	ret        	;;  Don't delete this line...you need it	
FixedSin ENDP 
	
FixedCos PROC angle:FXPT
	add angle, PI_HALF
	invoke FixedSin, angle

	ret        	;;  Don't delete this line...you need it		
FixedCos ENDP	

abs_diff PROC USES edx x:DWORD, y:DWORD
	mov eax, x
	mov edx, y
	cmp eax, edx
	jge @F
	xchg eax, edx
@@:	
	sub eax, edx	
	ret
abs_diff ENDP

int_to_fixed PROC x:DWORD
	mov eax, x
	shl eax, 16

	ret
int_to_fixed ENDP

fixed_to_int PROC x:DWORD
	mov eax, x
	shr eax, 16

	ret
fixed_to_int ENDP

plot PROC USES ebx ecx x:DWORD, y:DWORD, color:DWORD
	mov eax, y
	mov ebx, ROW_WIDTH
	mul ebx 		;; get the number of bytes of rows we're taking up
	add eax, x		;; add the offset for x
	mov ebx, color
	mov ecx, ScreenBitsPtr
	mov BYTE PTR [ecx + eax], bl

	ret
plot ENDP	

DrawLine PROC USES ebx ecx esi x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
	invoke abs_diff, y1, y0	;; ABS(y1-y0)
	mov ebx, eax		;; ebx = ABS(y1-y0)
	invoke abs_diff, x1, x0	;; ABS(x1-x0)
	cmp ebx, eax 	  	;; ABS(y1-y0) < ABS(x1-x0)
	jge case2
case1:
	mov ebx, x1 		;; x1 - x0
	sub ebx, x0
	invoke int_to_fixed, ebx
	mov esi, eax		;; store INT_TO_FIXED(x1-x0) in esi
	mov ebx, y1
	sub ebx, y0
	invoke int_to_fixed, ebx
	mov edx, eax
	sar edx, 16
	shl eax, 16
	idiv esi 		;; INT_TO_FIXED(y1-y0)/INT_TO_FIXED(x1-x0);
	mov fixed_inc, eax 

	mov eax, x0
	cmp eax, x1
	jle x0x1else
	mov eax, x1		;; swap x0 and x1
	mov ebx, x0
	mov x1, ebx
	mov x0, eax
	invoke int_to_fixed, y1	
	mov fixed_j, eax		
	jmp for_x0_to_x1

x0x1else:	
	invoke int_to_fixed, y0
	mov fixed_j, eax

for_x0_to_x1:
	mov eax, x0
	mov i, eax

for_x0_to_x1_cmp:
	mov eax, x1
	cmp i, eax
	je done

for_x0_to_x1_body:
	invoke fixed_to_int, fixed_j
	invoke plot, i, eax, color
	mov eax, fixed_inc
	add fixed_j, eax
	add i, 1
	jmp for_x0_to_x1_cmp

case2:
	mov eax, y1
	cmp eax, y0
	je done
	sub eax, y0
	invoke int_to_fixed, eax	;; int_to_fixed(y1-y0)
	mov esi, eax			;; store in esi
	mov eax, x1
	sub eax, x0
	invoke int_to_fixed, eax
	mov edx, eax
	sar edx, 16
	shl eax, 16
	idiv esi 			;; int_to_fixed(x1-x0) / int_to_fixed(y1-y0)
	mov fixed_inc, eax
	
	mov eax, y0
	cmp eax, y1
	jle y0y1else			;; y0>y1
	mov ebx, y0
	mov eax, y1
	mov y1, ebx
	mov y0, eax
	invoke int_to_fixed, x1
	mov fixed_j, eax
	jmp for_y0_to_y1

y0y1else:
	invoke int_to_fixed, x0
	mov fixed_j, eax
	
for_y0_to_y1:
	mov eax, y0
	mov i, eax

for_y0_to_y1_cmp:
	mov eax, y1
	cmp eax, i
	je done

for_y0_to_y1_body:
	invoke fixed_to_int, fixed_j
	invoke plot, eax, i, color
	mov eax, fixed_inc
	add fixed_j, eax
	add i, 1
	jmp for_y0_to_y1_cmp

done:
	ret        	;;  Don't delete this line...you need it
DrawLine ENDP


END
