; twocalc.asm
; Andrew Coleman
; This contains several algorithms for performing calculations on
; two dimensional matrices.
include irvine32.inc

MAXIMUM_COLUMN_SIZE = 10

.data

matrix_row_length dword 4 * MAXIMUM_COLUMN_SIZE
element_input_message byte "Enter matrix element: ",0
left_coordinate_message byte "(",0
middle_coordinate_message byte ",",0
right_coordinate_message byte ")",0

.code

; Fills a matrix with user supplied values.
;  Arguments:
; 1. address of array
; 2. address of the row counting variable
; 3. address of the column counting variable
PopulateMatrixWithUserValues proc
	push ebp
	mov ebp, esp
	pushad
	mov edi, [ebp + 08h]
	mov ebx, 0
StartMatrixElementRow:
	mov esi, edi
	mov ecx, 0
GetMatrixElement:
	mov edx, offset left_coordinate_message
	call writeString
	mov eax, ebx
	call writeInt
	mov edx, offset middle_coordinate_message
	call writeString
	mov eax, ecx
	call writeInt
	mov edx, offset right_coordinate_message
	call writeString
	mov edx, offset element_input_message
	call writeString
	call readInt
	mov [esi], eax
	add esi, 4
	inc ecx
	mov eax, [ebp + 10h]
	cmp ecx, [eax]
	jl GetMatrixElement
	inc ebx
	mov eax, [ebp + 0Ch]
	cmp ebx, [eax]
	je FinishUpMatrixInputAndReturn
	add edi, matrix_row_length
	jmp StartMatrixElementRow
FinishUpMatrixInputAndReturn:
	popad
	pop ebp
	ret 12
PopulateMatrixWithUserValues endp

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
