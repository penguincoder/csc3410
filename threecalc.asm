; threecalc.asm
; Andrew Coleman
; This contains several algorithms for performing calculations on
; two dimensional matrices.
include irvine32.inc

MAXIMUM_COLUMN_SIZE = 10

.data

matrix_row_length dword 4 * MAXIMUM_COLUMN_SIZE

.code

; CountPositiveMatrixElements counts the number of elements greater than 0
; Arguments:
;  1. Address of array
;  2. Address of row counter
;  3. Address of column counter
;  4. Address of result counter
CountPositiveMatrixElements proc
	push ebp
	mov ebp, esp
	pushad
	mov edi, [ebp + 08h]
	mov eax, [ebp + 0Ch]
	mov edx, [eax]
	xor esi, esi
BeginCountingElementsInRow:
	push edi
	mov eax, [ebp + 10h]
	mov ecx, [eax]
CountInRow:
	mov eax, [edi]
	cmp eax, 0
	jl FinishUpElementAndContinueCounting
	inc esi
FinishUpElementAndContinueCounting:
	add edi, 4
	dec ecx
	jg CountInRow
	pop edi
	add edi, matrix_row_length
	dec edx
	jg BeginCountingElementsInRow
	mov eax, [ebp + 14h]
	mov [eax], esi
	popad
	pop ebp
	ret 16
CountPositiveMatrixElements endp

; SumMatrixDiagonalSquares
; Arguments:
;  1. Address of array
;  2. Address of dimension
;  3. Address of result counter
SumMatrixDiagonalSquares proc
	push ebp
	mov ebp, esp
	pushad
	mov edi, [ebp + 08h]
	mov eax, [ebp + 0Ch]
	mov ecx, [eax]
	xor esi, esi
DiagonalCount:
	mov eax, [edi]
	imul eax
	add esi, eax
	add edi, matrix_row_length
	add edi, 4
	dec ecx
	jg DiagonalCount
	mov eax, [ebp + 10h]
	mov [eax], esi
	popad
	pop ebp
	ret 12
SumMatrixDiagonalSquares endp

; SumMatrices
; Arguments
;  1. Address of first matrix
;  2. Address of second matrix
;  3. Address of third matrix
;  4. Address of row counter
;  5. Address of column counter
SumMatrices proc
	push ebp
	mov ebp, esp
	pushad
	mov edi, [ebp + 08h]
	mov esi, [ebp + 0Ch]
	mov edx, [ebp + 10h]
	mov eax, [ebp + 14h]
	mov ebx, [eax]
StartMatrixRow:
	mov eax, [ebp + 18h]
	mov ecx, [eax]
	push edi
	push esi
	push edx
CalculateMatrixRow:
	mov eax, [edi]
	add eax, [esi]
	mov [edx], eax
	add edi, 4
	add esi, 4
	add edx, 4
	dec ecx
	jg CalculateMatrixRow
	pop edx
	pop esi
	pop edi
	add edx, matrix_row_length
	add esi, matrix_row_length
	add edi, matrix_row_length
	dec ebx
	jg StartMatrixRow
	popad
	pop ebp
	ret 20
SumMatrices endp

end
