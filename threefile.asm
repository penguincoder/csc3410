; threefile.asm
; This file contains all of the file-driven procedures for
; the matrix input and output.

include irvine32.inc

MAX_FILENAME_SIZE = 120
DEFAULT_BUFFER_SIZE = 80
MAXIMUM_COLUMN_SIZE = 10

.data

matrix_row_length dword 4 * MAXIMUM_COLUMN_SIZE

error_message byte "Could not open the file... bailing",0Dh,0Ah,0
filename_message byte "Enter name of file ( <120 chars ): ",0
buffer_size_message byte "Enter size of input buffer ( <=500 ): ",0
cmsg byte "format int: ",0

filename dword MAX_FILENAME_SIZE dup (?)
filename_size dword ?

consolehandle dword ?
filestruct label dword
file_handle dword ?
file_buffer byte 500 dup (?)
buffer_size dword ?
bytes_remaining dword ?
buffer_offset dword ?

number_flag dword ?
negative_flag dword ?

.code

InitFile proc
	pushad
	mov edx, offset filename_message
	call writeString
	mov edx, offset filename
	mov ecx, MAX_FILENAME_SIZE
	call readString
	mov filename_size, eax
	mov edx, offset buffer_size_message
	call writeString
	call readInt
	cmp eax, 1
	jl BadBufferSize
	cmp eax, 500
	jle GoodBufferSize
BadBufferSize:
	mov eax, DEFAULT_BUFFER_SIZE
GoodBufferSize:
	mov buffer_size, eax
	push 0
	push FILE_ATTRIBUTE_NORMAL
	push OPEN_EXISTING
	push NULL
	push DO_NOT_SHARE
	push GENERIC_READ
	push offset filename
	call CreateFile
	mov file_handle, eax
	cmp eax, INVALID_HANdlE_VALUE
	jne Continue
	call QuitProgramByError
Continue:
	push STD_OUTPUT_HANDLE
	call GetStdHandle
	mov consolehandle, eax
	call Crlf
	popad
	ret
InitFile endp

QuitProgramByError proc
	mov edx, offset error_message
	call writeString
	exit
QuitProgramByError endp

CloseFile proc
	push file_handle
	call closeHandle
	ret
CloseFile endp

; Formats a computer integer into an output buffer
; Arguments:
; 1. Address of Buffer
; 2. Number to format
FormatInteger proc
	push ebp
	mov ebp, esp
	pushad
	mov edi, [ebp + 08h]
	add edi, buffer_size
	dec edi
	mov eax, [ebp + 0Ch]
	mov negative_flag, 0
	mov ebx, 10
	cmp eax, 0
	jge ProcessNumber
	mov negative_flag, 1
	neg eax
ProcessNumber:
	cdq
	idiv ebx
	add dl, 30h
	mov byte ptr [edi], dl
	dec edi
	cmp eax, 0
	jnz ProcessNumber
	cmp negative_flag, 1
	jne FinishFormatNumber
	mov dl, '-'
	mov byte ptr [edi], dl
FinishFormatNumber:
	popad
	pop ebp
	ret 8
FormatInteger endp

; PrettyPrintMatrix displays a matrix in a pretty format using tabs.
; Arguments:
;  1. Address of array
;  2. Row value of matrix
;  3. Column value of matrix
;  4. Address of string message to display
PrettyPrintMatrix proc
	push ebp
	mov ebp, esp
	pushad
	mov edi, [ebp + 08h]
	mov edx, [ebp + 14h]
	call writeString
	call Crlf
	mov buffer_size, 8
	mov ebx, [ebp + 0Ch]
PrettyPrintMatrixBeginRow:
	mov ecx, DEFAULT_BUFFER_SIZE
	mov esi, offset file_buffer
StartBlank:
	mov byte ptr [esi], ' '
	inc esi
	dec ecx
	jg StartBlank
	push edi
	mov ecx, [ebp + 10h]
	mov esi, offset file_buffer
PrettyPrintMatrixPrintRow:
	push [edi]
	push esi
	call FormatInteger
	add edi, 4
	add esi, buffer_size
	dec ecx
	je PrettyPrintMatrixEndOfRow
	jmp PrettyPrintMatrixPrintRow
PrettyPrintMatrixEndOfRow:
	push 0
	push offset bytes_remaining
	push DEFAULT_BUFFER_SIZE
	push offset file_buffer
	push consolehandle
	call WriteConsole
	pop edi
	add edi, matrix_row_length
	dec ebx
	jg PrettyPrintMatrixBeginRow
	popad
	pop ebp
	ret 16
PrettyPrintMatrix endp

; This procedure reads in a series of ascii numbers from a file
; and fills the two respective matrices with values
; Arguments:
; 1. offset of first matrix
; 2. offset of second matrix
; 3. offset of matrix 1's row
; 4. offset of matrix 1's column
; 5. offset of matrix 2's row
; 6. offset of matrix 2's column
PopulateMatrixWithFileValues proc
	push ebp
	mov ebp, esp
	pushad
	mov edi, [ebp + 10h]
	mov esi, [ebp + 14h]
	push edi
	call ReadInteger
	mov eax, [edi]
	cmp eax, 1
	jl BadOneRow
	cmp eax, 10
	jl GoodOneRow
BadOneRow:
	mov eax, 1
	mov [edi], eax
GoodOneRow:
	push esi
	call ReadInteger
	mov eax, [esi]
	cmp eax, 1
	jl BadOneCol
	cmp eax, 10
	jl GoodOneCol
BadOneCol:
	mov eax, 1
	mov [esi], eax
GoodOneCol:
	mov edi, [ebp + 08h]
	mov ebx, 0
StartMatrixOneElementRow:
	mov esi, edi
	mov ecx, 0
GetMatrixOneElement:
	push esi
	call ReadInteger
	add esi, 4
	inc ecx
	mov eax, [ebp + 14h]
	cmp ecx, [eax]
	jl GetMatrixOneElement
	inc ebx
	mov eax, [ebp + 10h]
	cmp ebx, [eax]
	je StartMatrixTwo
	add edi, matrix_row_length
	jmp StartMatrixOneElementRow
StartMatrixTwo:
	mov edi, [ebp + 18h]
	mov esi, [ebp + 1Ch]
	push edi
	call ReadInteger
	mov eax,[edi]
	cmp eax, 1
	jl BadTwoRow
	cmp eax, 10
	jl GoodTwoRow
BadTwoRow:
	mov eax, 1
	mov [edi], eax
GoodTwoRow:
	push esi
	call ReadInteger
	mov eax, [esi]
	cmp eax, 1
	jl BadTwoCol
	cmp eax, 10
	jl GoodTwoCol
BadTwoCol:
	mov eax, 1
	mov [esi], eax
GoodTwoCol:
	mov edi, [ebp + 0Ch]
	mov ebx, 0
StartMatrixTwoElementRow:
	mov esi, edi
	mov ecx, 0
GetMatrixTwoElement:
	push esi
	call ReadInteger
	add esi, 4
	inc ecx
	mov eax, [ebp + 1Ch]
	cmp ecx, [eax]
	jl GetMatrixTwoElement
	inc ebx
	mov eax, [ebp + 18h]
	cmp ebx, [eax]
	je FinishUpMatrixTwo
	add edi, matrix_row_length
	jmp StartMatrixTwoElementRow
FinishUpMatrixTwo:
	popad
	pop ebp
	ret 24
PopulateMatrixWithFileValues endp

; This procedure reads an integer out of the input buffer and returns
; the parsed value into a dword. This implementation does not
; require the file structure to be passed to this procedure
; Arguments:
; 1. offset of parsed value
ReadInteger proc
	push ebp
	mov ebp, esp
	pushad
	mov ecx, bytes_remaining
	mov ebx, buffer_offset
	mov esi, offset file_buffer
	mov number_flag,	0
	mov negative_flag,	0
	mov eax, 0
BufferEmpty:
	cmp ecx, 0
	jne ComputeIntegerFromByte
	push eax
	push 0
	push offset bytes_remaining
	push buffer_size
	push offset file_buffer
	push file_handle
	call ReadFile
	pop eax
	mov ecx, bytes_remaining
	mov ebx, 0
	cmp ecx, 0
	je SaveInteger
ComputeIntegerFromByte:
	mov edx, 0
	mov dl, [esi+ebx]
	cmp dl, '-'
	jne PositiveInteger
	mov negative_flag, 1
	mov number_flag, 1
	jmp ContinueInteger
PositiveInteger:
	cmp dl, '+'
	jne IsAsciiDigit
	mov number_flag, 1
	jmp ContinueInteger
IsAsciiDigit:
	cmp dl, '9'
	jg BadDigit
	cmp dl, '0'
	jl BadDigit
GoodDigit:
	mov number_flag, 1
	push edx
	imul eax, 10
	pop  edx
	sub  dl, 30h
	add  eax, edx
ContinueInteger:
	inc ebx
	dec ecx
	jmp BufferEmpty
BadDigit:
	cmp number_flag, 0
	je ContinueInteger
IntegerEnd:
	cmp negative_flag, 1
	jne SaveInteger
	neg eax
SaveInteger:
	mov edi, [ebp+08h]
	mov [edi], eax
	mov bytes_remaining, ecx
	mov buffer_offset, ebx
	popad
	pop ebp
	ret 4
ReadInteger endp

end
