; #########################################################################
;
;   blit.asm - Assembly file for EECS205 Assignment 3
;   Andy Bayer - arb495
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include blit.inc

.DATA

	;; If you need to, you can place global variables here
      allPurpose DWORD ?
      counter DWORD ?
      transparent BYTE ?
.CODE


;; happy helper function
FixedMul PROC USES edx, x:DWORD, y:DWORD
    mov eax, x
    imul y
    shr eax, 16
    shl edx, 16
    add eax, edx
    ret
FixedMul ENDP

DrawPixel PROC USES ebx ecx edx x:DWORD, y:DWORD, color:BYTE
    mov ebx, ScreenBitsPtr
    mov edx, 0
    mov ecx, y
    mov eax, 640
    imul ecx
    add eax, x
    mov dl, color
    mov BYTE PTR [ebx + eax], dl
    ret
DrawPixel ENDP

BasicBlit PROC USES ebx ecx edx edi esi ptrBitmap:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD
    LOCAL screenX:DWORD
    LOCAL screenY:DWORD
    LOCAL dwWidth:DWORD
    LOCAL dwHeight:DWORD
    LOCAL dwHalfWidth:DWORD
    LOCAL dwHalfHeight:DWORD
    
    mov eax, ptrBitmap
    mov ebx, (EECS205BITMAP PTR[eax]).dwWidth
    mov dwWidth, ebx
    shr ebx, 1
    mov dwHalfWidth, ebx

    mov ebx, (EECS205BITMAP PTR[eax]).dwHeight
    mov dwHeight, ebx
    shr ebx, 1
    mov dwHalfHeight, ebx

    mov bl, (EECS205BITMAP PTR [eax]).bTransparent
    mov transparent, bl

Body:
    mov ebx, xcenter     ;xpos
    sub ebx, dwHalfWidth ;xcenter - width/2
    mov ecx, ycenter     
    sub ecx, dwHalfHeight
    mov edi, (EECS205BITMAP PTR [eax]).lpBytes
    mov esi, ScreenBitsPtr
    jmp Checks

IncRow:
    mov ebx, xcenter
    sub ebx, dwHalfWidth
    add ecx, 1              ;;incrow
    mov eax, ycenter
    add eax, dwHalfHeight
    cmp ecx, eax            ;; if the new row is out of bounds we are finished
    jl Checks
    ret

Checks:
    cmp ebx, 0
    jl MoveUp
    cmp ebx, 639
    jg MoveUp
    cmp ecx, 0
    jl MoveUp
    cmp ecx, 479
    jg MoveUp

Draw:
    mov dl, [edi]       ;; the pointer to the sprite bytes
    cmp dl, transparent
    je MoveUp
    INVOKE DrawPixel, ebx, ecx, dl  ;; if it's not transparent, draw it
    
MoveUp:     ;; this is where the pointers are moved up and the column is moved up
    mov eax, xcenter
    add eax, dwHalfWidth
    cmp ebx, eax
    jge IncRow          ;; if we're at the end of the sprite, move up a row
    add ebx, 1          ;; move up a byte
    add edi, 1
    jmp Checks

    ret    	;;  Do not delete this line!
BasicBlit ENDP

	

RotateBlit PROC USES ebx ecx edi esi edx lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT
    LOCAL cosa:DWORD
    LOCAL sina:DWORD
    LOCAL dwWidth:DWORD
    LOCAL dwHeight:DWORD
    LOCAL shiftX:DWORD
    LOCAL shiftY:DWORD
    LOCAL dstWidth:DWORD
    LOCAL dstHeight:DWORD
    LOCAL dstX:DWORD
    LOCAL dstY:DWORD
    LOCAL srcX:DWORD
    LOCAL srcY:DWORD
    LOCAL screenY:DWORD
    LOCAL screenX:DWORD
    LOCAL lpBytes:DWORD
    LOCAL lpBitmapPtr:BYTE     ;; will hold the byte to draw
    LOCAL color:BYTE

    INVOKE FixedCos, angle
    mov cosa, eax
    INVOKE FixedSin, angle
    mov sina, eax

    mov eax, lpBmp

    mov ebx, (EECS205BITMAP PTR [eax]).lpBytes
    mov lpBytes, ebx
    mov ebx, (EECS205BITMAP PTR [eax]).dwWidth
    mov dwWidth, ebx
    mov ebx, (EECS205BITMAP PTR [eax]).dwHeight
    mov dwHeight, ebx
    mov bl, (EECS205BITMAP PTR [eax]).bTransparent
    mov transparent, bl

CalculateVals:
    ;; here's where i'll calculate shiftx, shifty and dstwidth
    ;; shiftx first
    mov ebx, dwWidth
    shr ebx, 1
    INVOKE FixedMul, cosa, ebx
    mov shiftX, eax

    mov edx, dwHeight
    shr edx, 1
    INVOKE FixedMul, sina, edx
    sub shiftX, eax    

    ;; shifty
    mov ebx, dwHeight
    shr ebx, 1
    INVOKE FixedMul, cosa, ebx
    mov shiftY, eax

    mov ebx, dwHeight
    shr ebx, 1
    INVOKE FixedMul, cosa, ebx
    mov shiftY, eax

    mov edx, dwHeight
    shr edx, 1
    INVOKE FixedMul, sina, edx
    add shiftY, eax

    ;; dswtwidth and dstheight now
    mov eax, dwWidth
    add eax, dwHeight
    mov dstWidth, eax
    mov dstHeight, eax
    mov ebx, dstHeight  ;; negate the height for the loop
    neg ebx
    mov dstY, ebx

IncRow:
    mov ecx, dstWidth
    neg ecx
    mov dstX, ecx

IncCol:
    ;; calculate srcx
    mov eax, dstX
    imul cosa
    sar eax, 16
    mov ebx, eax

    mov eax, dstY
    imul sina
    sar eax, 16
    add eax, ebx
    mov srcX, eax

    ;; srcy
    mov eax, dstY
    imul cosa
    sar eax, 16
    mov ebx, eax

    mov eax, dstX
    imul sina
    sar eax, 16
    sub ebx, eax
    mov srcY, ebx

    ;; if clause    
    mov ebx, srcX
    cmp ebx, 0
    jl Checks
    cmp ebx, dwWidth
    jge Checks

    mov ebx, srcY
    cmp ebx, 0
    jl Checks
    cmp ebx, dwHeight
    jge Checks

    mov edx, 0
    sub edx, shiftX
    add edx, xcenter
    add edx, dstX
    mov screenX, edx
    cmp edx, 0
    jl Checks
    cmp edx, 639
    jge Checks

    mov edx, 0
    sub edx, shiftY
    add edx, dstY
    add edx, ycenter
    mov screenY, edx
    cmp edx, 0
    jl Checks
    cmp edx, 479
    jge Checks
    

    ;; check for transparency
    mov eax, srcY
    mov esi, dwWidth
    mul esi
    add eax, srcX
    add eax, lpBytes

    mov cl, BYTE PTR [eax]
    mov color, cl
    cmp cl, transparent
    je Checks

Draw:
    INVOKE DrawPixel, screenX, screenY, color

Checks:
    ;; this is where we go if we fail any checks
    inc dstX
    mov ebx, dstX
    cmp ebx, dstWidth
    jl IncCol

    inc dstY
    mov ebx, dstY
    cmp ebx, dstHeight
    jl IncRow

    ret
	
RotateBlit ENDP


CheckIntersectRect PROC USES ebx ecx edx one:PTR EECS205RECT, two:PTR EECS205RECT
    ;; basically ecx is going to hold the side of rect 1 being checked
    ;; and edx will hold the same side of rect 2
    ;; go through the sides: if there's the right condition on all
    ;; then there is intersection
    mov eax, one
    mov ebx, two
    mov ecx, (EECS205RECT PTR [eax]).dwLeft ;;get left sides
    mov edx, (EECS205RECT PTR [ebx]).dwLeft 
    cmp ecx, edx
    jg RectTwoLeftSide
RectOneLeftSide:
    mov ecx, (EECS205RECT ptr [EAX]).dwRight
    cmp ecx, edx
    jge Stacked
    jmp None
RectTwoLeftSide:
    mov edx, (EECS205RECT PTR [ebx]).dwRight
    cmp edx, ecx
    jge Stacked
    jmp None
Stacked:
    mov ecx, (EECS205RECT PTR [eax]).dwTop
    mov edx, (EECS205RECT PTR [ebx]).dwTop
    cmp ecx, edx
    jg RectTwoTop
RectOneTop:
    mov ecx, (EECS205RECT PTR [eax]).dwBottom
    cmp ecx, edx
    jge Intersecting
    jmp None
RectTwoTop:
    mov edx, (EECS205RECT PTR [ebx]).dwBottom
    cmp edx, ecx
    jge Intersecting
    jmp None
Intersecting:
    mov eax, 1
    ret
None:
    mov eax, 0
    ret
	
CheckIntersectRect ENDP


END
