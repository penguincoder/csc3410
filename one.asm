include irvine32.inc

CR=0Dh
LF=0Ah
NULL=0

.data

; simple numbers to keep track of various bits of information about the array
array dword 100 dup (?)
avg dword ?
pdelt dword ?
ndelt dword ?
dev dword ?
numa dword ?
numb dword ?
numc dword ?
numd dword ?
numf dword ?
n dword ?
gradereport dword ?

; string messages for I/O
imsg byte "input a number or 999 to quit: ",NULL
mainmsg byte CR,LF,"array analysis",CR,LF,NULL
minmsg byte "minimum value: ",NULL
maxmsg byte "maximum value: ",NULL
summsg byte "sum of values: ",NULL
avgmsg byte "avg of values: ",NULL
posmsg byte "most positive change from x[i] to x[i+1]: ",NULL
negmsg byte "most negative change from x[i] to x[i+1]: ",NULL
devmsg byte "average deviation from mean: ",NULL
amsg byte "Number of A's ",NULL
bmsg byte "Number of B's ",NULL
cmsg byte "Number of C's ",NULL
dmsg byte "Number of D's ",NULL
fmsg byte "Number of F's ",NULL
nogrademsg byte "This is not a grade report",CR,LF,NULL
goodbyemsg byte "Goodbye",CR,LF,NULL

.code

main proc

; counter
mov ecx, 0
; average
mov avg, 0
; values for max / min
mov edi, 0
mov edx, 0
; values for pos / neg delt
mov pdelt, 0
mov ndelt, 0
; sum of values
mov ebx, 0
; array pointer
mov esi, offset array
; flag for gradereport
mov gradereport, 0

; read in all numbers, find maximum, find minimum, add sum, calc average, and determine if a grade report is needed
ReadAnotherInt:
 push edx
 mov edx, offset imsg
 call writeString
 call readInt
 pop edx
 cmp eax, 999
 je CheckForValidity
 inc ecx
 mov [esi], eax
 add ebx, eax
 cmp eax, edx
 jg SetMax
 jmp CheckMinimum
SetMax:
 mov edx, eax
CheckMinimum:
 cmp ecx, 1
 jg CheckMinimum2
 mov edi, eax
 jmp DoneMaxMinCheck
CheckMinimum2:
 cmp eax, edi
 jg DoneMaxMinCheck
 mov edi, eax
DoneMaxMinCheck:
 cmp ecx, 1
 jle ReadAnotherInt2
 sub eax, [esi-04h]
 cmp eax, edi
 jge CheckPosDelt
 mov ndelt, eax
 jmp ReadAnotherInt2
CheckPosDelt:
 cmp eax, pdelt
 jle CheckMinDelt
 mov pdelt, eax
CheckMinDelt:
 cmp eax, ndelt
 jg ReadAnotherInt2
 mov ndelt, eax
ReadAnotherInt2:
 add esi, 4
 jmp ReadAnotherInt

; only calculate things if someone entered some values
CheckForValidity:
 mov n, ecx
 cmp ecx, 0
 jg DisplayMaxMin
 jmp GoodBye

; show all the maximums and minimums that the program has calculated
DisplayMaxMin:
 push edx
 mov edx, offset mainmsg
 call writeString
 mov edx, offset maxmsg
 call writeString
 pop edx
 mov eax, edx
 call writeInt
 call Crlf
 cmp edx, 100
 jg ContinueWithDisplayMaxMin
 cmp edi, 0
 jl ContinueWithDisplayMaxMin
 mov gradereport, 1
ContinueWithDisplayMaxMin:
 mov edx, offset minmsg
 call writeString
 mov eax, edi
 call writeInt
 call Crlf
 mov edx, offset summsg
 call writeString
 mov eax, ebx
 call writeInt
 call Crlf
 mov edx, offset avgmsg
 call writeString
 cdq
 idiv n
 mov avg, eax
 call writeInt
 call Crlf
 mov edx, offset posmsg
 call writeString
 mov eax, pdelt
 call writeInt
 call Crlf
 mov edx, offset negmsg
 call writeString
 mov eax, ndelt
 call writeInt
 call Crlf

mov ebx, 0
CalculateDeviation:
 mov eax, [esi]
 sub eax, avg
 cmp eax, 0
 jg CalculateDeviation2
 neg eax
CalculateDeviation2:
 sub esi, 4
 add ebx, eax
 loopd CalculateDeviation
; finalize calculations for deviation
mov eax, ebx
mov ecx, n
cdq
idiv ecx
mov edx, offset devmsg
call writeString
call writeInt
call Crlf

; determine if a grade report is needed
cmp gradereport, 1
je CalcGrades
call Crlf
mov edx, offset nogrademsg
call writeString
jmp GoodBye

mov numa, 0
mov numb, 0
mov numc, 0
mov numd, 0
mov numf, 0
mov ecx, n
mov esi, offset array
sub esi, 4
CalcGrades:
 add esi, 4
 mov eax, [esi]
 cmp eax, 90
 jl CheckForB
 inc numa
 loopd CalcGrades
CheckForB:
 cmp eax, 80
 jl CheckForC
 inc numb
 loopd CalcGrades
CheckForC:
 cmp eax, 70
 jl CheckForD
 inc numc
 loopd CalcGrades
CheckForD:
 cmp eax, 60
 jl Flunked
 inc numd
 loopd CalcGrades
Flunked:
 inc numf
 loopd CalcGrades
call Crlf
mov edx, offset amsg
call writeString
mov eax, numa
call writeInt
call Crlf
mov edx, offset bmsg
call writeString
mov eax, numb
call writeInt
call Crlf
mov edx, offset cmsg
call writeString
mov eax, numc
call writeInt
call Crlf
mov edx, offset dmsg
call writeString
mov eax, numd
call writeInt
call Crlf
mov edx, offset fmsg
call writeString
mov eax, numf
call writeInt
call Crlf

GoodBye:
mov edx, offset goodbyemsg
call writeString
exit
main endp

end main
