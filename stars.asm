; #########################################################################
;
;   stars.asm - Assembly file for EECS205 Assignment 1
;   ANDY BAYER
;
; #########################################################################

.586
.MODEL FLAT,STDCALL
.STACK 4096
option casemap :none  ; case sensitive


include stars.inc

.DATA

	;; If you need to, you can place global variables here

.CODE

DrawStarField proc

	;; Place your code here
  invoke DrawStar, 12, 12
	invoke DrawStar, 24, 24
  invoke DrawStar, 36, 36
  invoke DrawStar, 42, 42
  invoke DrawStar, 100, 100
  invoke DrawStar, 112, 112
  invoke DrawStar, 12, 30

	ret  			; Careful! Don't remove this line
DrawStarField endp


AXP	proc a:FXPT, x:FXPT, p:FXPT

	;; Place your code here
  mov eax, a		; move operands into registers
	mov ecx, x
	imul ecx     	; signed multiplication
	shr eax, 16		; shift fractional MSB right
	shl edx, 16		; shift integral LSB left
	add eax, edx 	; combine fractional and integral bits
	add eax, p		; add p
	;; Remember that the return value should be copied in to EAX

	ret  			; Careful! Don't remove this line
AXP	endp



END
