; three.asm
; This program should demonstrate various capabilities of assembly
; calculations of contiguous chunks of memory (i.e. arrays).
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

.code

main proc
	PopulateMatrixWithFileValues proto
	CountPositiveMatrixElements proto
	SumMatrixDiagonalSquares proto
	SumMatrices proto
	PrettyPrintMatrix proto
	InitFile proto
	CloseFile proto

	call InitFile
	push offset matrix_two_column_size
	push offset matrix_two_row_size
	push offset matrix_one_column_size
	push offset matrix_one_row_size
	push offset matrix_two
	push offset matrix_one
	call PopulateMatrixWithFileValues
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
	call CloseFile
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
	push matrix_one_column_size
	push matrix_one_row_size
	push offset matrix_one
	call PrettyPrintMatrix
	push offset matrix_two_initial_message
	push matrix_two_column_size
	push matrix_two_row_size
	push offset matrix_two
	call PrettyPrintMatrix
	cmp matrix_sum_exists, 0
	je DoneWithDisplaying
	push offset matrix_three_initial_message
	push matrix_one_column_size
	push matrix_one_row_size
	push offset matrix_three
	call PrettyPrintMatrix
DoneWithDisplaying:
	exit
main endp

end main
