; two.asm
; This program should demonstrate various capabilities of assembly
; calculations of contiguous chunks of memory.
; This program will logically assign and populate values in two arrays,
; find the total number of positive elements in the first,
; the sum of the squares of the diagonal if the matrix is square,
; and then compute the sum of the two arrays if possible
include irvine32.inc

MAXIMUM_COLUMN_SIZE = 10

.data

matrix_row_length dword 4 * MAXIMUM_COLUMN_SIZE

matrix_one dword 100 dup (?)
matrix_two dword 100 dup (?)
matrix_three dword 100 dup (?)

matrix_one_row_size dword ?
matrix_one_column_size dword ?
matrix_two_row_size dword ?
matrix_two_column_size dword ?

random_calculation_variable dword ?
matrix_sum_exists dword ?

matrix_one_initial_message byte "Initial First Matrix",0
matrix_one_positive_count_message byte "Number of positive elements in first matrix: ",0
matrix_one_diagonal_square_count_message byte "Sum of squares of main diagonal in first matrix: ",0
matrix_two_initial_message byte "Initial Second Matrix",0
matrix_three_initial_message byte "Sum Matrix = First Matrix + Second Matrix",0

row_dimension_message byte "Enter number of rows: ",0
column_dimension_message byte "Enter number of columns: ",0

tab_character byte 09h

; best phone number in the world: 256 512 1024
.code

; Returns the dimensions of a matrix
;  Arguments:
; 1. address of row size variable
; 2. address of column size variable
; 3. address of message to display
;  Caveats:
; Returns 1 in place of numbers less than 1 and greater than 10
GetArrayDimensions proc
	push ebp
	mov ebp, esp
	push eax
	push edx
	push ebx
	mov edx, [ebp + 10h]
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
	mov ebx, [ebp + 08h]
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
	mov ebx, [ebp + 0Ch]
	mov [ebx], eax
	pop ebx
	pop edx
	pop eax
	pop ebp
	ret 12
GetArrayDimensions endp

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

main proc
	PopulateMatrixWithUserValues proto
	CountPositiveMatrixElements proto
	SumMatrixDiagonalSquares proto
	SumMatrices proto
	
	push offset matrix_one_initial_message
	push offset matrix_one_column_size
	push offset matrix_one_row_size
	call GetArrayDimensions
	call Crlf
	push offset matrix_two_initial_message
	push offset matrix_two_column_size
	push offset matrix_two_row_size
	call GetArrayDimensions
	call Crlf
	push offset matrix_one_column_size
	push offset matrix_one_row_size
	push offset matrix_one
	call PopulateMatrixWithUserValues
	call Crlf
	push offset matrix_two_column_size
	push offset matrix_two_row_size
	push offset matrix_two
	call PopulateMatrixWithUserValues
	call Crlf
	push offset random_calculation_variable
	push offset matrix_one_column_size
	push offset matrix_one_row_size
	push offset matrix_one
	call CountPositiveMatrixElements
	mov edx, offset matrix_one_positive_count_message
	call writeString
	mov eax, random_calculation_variable
	call writeInt
	call Crlf
BeginCalculations:
	mov eax, matrix_one_row_size
	xor eax, matrix_one_column_size
	jne CalculateSum
	push offset random_calculation_variable
	push offset matrix_one_row_size
	push offset matrix_one
	call SumMatrixDiagonalSquares
	mov edx, offset matrix_one_diagonal_square_count_message
	call writeString
	mov eax, random_calculation_variable
	call writeInt
	call Crlf
CalculateSum:
	call Crlf
	mov matrix_sum_exists, 0
	mov eax, matrix_one_row_size
	xor eax, matrix_two_row_size
	jne DisplayMatrices
	mov eax, matrix_one_column_size
	xor eax, matrix_two_column_size
	jne DisplayMatrices
	inc matrix_sum_exists
	push offset matrix_one_column_size
	push offset matrix_one_row_size
	push offset matrix_three
	push offset matrix_two
	push offset matrix_one
	call SumMatrices
DisplayMatrices:
	push offset matrix_one_initial_message
	push offset matrix_one_column_size
	push offset matrix_one_row_size
	push offset matrix_one
	call PrettyPrintMatrix
	push offset matrix_two_initial_message
	push offset matrix_two_column_size
	push offset matrix_two_row_size
	push offset matrix_two
	call PrettyPrintMatrix
	cmp matrix_sum_exists, 0
	je DoneWithDisplaying
	push offset matrix_three_initial_message
	push offset matrix_one_column_size
	push offset matrix_one_row_size
	push offset matrix_three
	call PrettyPrintMatrix
DoneWithDisplaying:
	exit
main endp

end main
