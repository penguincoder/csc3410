; threeio.asm
; This file includes many different procedures for user-driven
; matrix input and output.

include irvine32.inc

MAXIMUM_COLUMN_SIZE = 10

.data

matrix_row_length dword 4 * MAXIMUM_COLUMN_SIZE

left_coordinate_message byte "(",0
middle_coordinate_message byte ",",0
right_coordinate_message byte ")",0

element_input_message byte "Enter matrix element: ",0
row_dimension_message byte "Enter number of rows: ",0
column_dimension_message byte "Enter number of columns: ",0

tab_character byte 09h,0

.code

; Fills a matrix with user supplied values.
;  Arguments:
; 1. address of array
; 2. address of the row counting variable
; 3. address of the column counting variable
; 4. address of message to display
;  Caveats:
; Forces 1 in place of numbers less than 1 and greater than 10 for dimensions
PopulateMatrixWithUserValues proc
	push ebp
	mov ebp, esp
	pushad
	;here is the old GetMatrixDimesions procedure
	mov edx, [ebp + 14h]
	call writeString
	call Crlf
	mov edx, offset row_dimension_message
	call writeString
	call readInt
	cmp eax, 1
	jl BadRowDimension
	cmp eax, 10
	jg BadRowDimension
	jmp GoodRowDimensionLabel
BadRowDimension:
	mov eax, 1
GoodRowDimensionLabel:
	mov ebx, [ebp + 0Ch]
	mov [ebx], eax
	mov edx, offset column_dimension_message
	call writeString
	call readInt
	cmp eax, 1
	jl BadColumnDimension
	cmp eax, 10
	jg BadColumnDimension
	jmp GoodColumnDimensionLabel
BadColumnDimension:
	mov eax, 1
GoodColumnDimensionLabel:
	mov ebx, [ebp + 10h]
	mov [ebx], eax
	;GetMatrixDimensions ends here
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
	ret 16
PopulateMatrixWithUserValues endp

; PrettyPrintMatrix displays a matrix in a pretty format using tabs.
; Arguments:
;  1. Address of array
;  2. Address of row counter
;  3. Address of column counter
;  4. Address of string message to display
PrettyPrintMatrix proc
	push ebp
	mov ebp, esp
	pushad
	mov edi, [ebp + 08h]
	mov edx, [ebp + 14h]
	call writeString
	call Crlf
	mov eax, [ebp + 0Ch]
	mov esi, [eax]
PrettyPrintMatrixBeginRow:
	push edi
	mov eax, [ebp + 10h]
	mov ecx, [eax]
PrettyPrintMatrixPrintRow:
	mov eax, [edi]
	call writeInt
	dec ecx
	je PrettyPrintMatrixEndOfRow
	mov edx, offset tab_character
	call writeString
	add edi, 4
	jmp PrettyPrintMatrixPrintRow
PrettyPrintMatrixEndOfRow:
	call Crlf
	pop edi
	add edi, matrix_row_length
	dec esi
	jg PrettyPrintMatrixBeginRow
	popad
	pop ebp
	ret 16
PrettyPrintMatrix endp

end