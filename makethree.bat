@echo off
set MASM=C:\Masm615
set PATH=%PATH%;%MASM%
set INCLUDE=%MASM%\include
set LIB=%MASM%\lib

ml -Zi -c -Fl -coff three.asm threecalc.asm threefile.asm
if errorLevel 1 goto endp
link32 three.obj threecalc.obj threefile.obj irvine32.lib kernel32.lib /subsystem:console /debug

:endp
