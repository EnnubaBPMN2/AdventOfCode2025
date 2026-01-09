@echo off
setlocal enabledelayedexpansion

:: Tool paths
set NASM="C:\Program Files\NASM\nasm.exe"
set LINKER="C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Tools\MSVC\14.44.35207\bin\Hostx64\x64\link.exe"
set KERNEL32="C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\um\x64\kernel32.Lib"

if not exist %NASM% (
    echo [ERROR] NASM not found at %NASM%
    exit /b 1
)

if not exist %LINKER% (
    echo [ERROR] Linker not found at %LINKER%
    exit /b 1
)

echo [INFO] Assembling...
%NASM% -f win64 main.asm -o main.obj
if %errorlevel% neq 0 exit /b %errorlevel%

%NASM% -f win64 io.asm -o io.obj
if %errorlevel% neq 0 exit /b %errorlevel%

%NASM% -f win64 print.asm -o print.obj
if %errorlevel% neq 0 exit /b %errorlevel%

%NASM% -f win64 parse.asm -o parse.obj
if %errorlevel% neq 0 exit /b %errorlevel%

%NASM% -f win64 day01.asm -o day01.obj
if %errorlevel% neq 0 exit /b %errorlevel%

%NASM% -f win64 day02.asm -o day02.obj
if %errorlevel% neq 0 exit /b %errorlevel%

%NASM% -f win64 day03.asm -o day03.obj
if %errorlevel% neq 0 exit /b %errorlevel%

%NASM% -f win64 day04.asm -o day04.obj
if %errorlevel% neq 0 exit /b %errorlevel%

%NASM% -f win64 day05.asm -o day05.obj
if %errorlevel% neq 0 exit /b %errorlevel%

%NASM% -f win64 day06.asm -o day06.obj
if %errorlevel% neq 0 exit /b %errorlevel%

%NASM% -f win64 day07.asm -o day07.obj
if %errorlevel% neq 0 exit /b %errorlevel%

%NASM% -f win64 day08.asm -o day08.obj
if %errorlevel% neq 0 exit /b %errorlevel%

%NASM% -f win64 day09.asm -o day09.obj
if %errorlevel% neq 0 exit /b %errorlevel%

%NASM% -f win64 day10.asm -o day10.obj
if %errorlevel% neq 0 exit /b %errorlevel%

echo [INFO] Linking...
%LINKER% main.obj io.obj print.obj parse.obj day01.obj day02.obj day03.obj day04.obj day05.obj day06.obj day07.obj day08.obj day09.obj day10.obj /subsystem:console /entry:main %KERNEL32% /LARGEADDRESSAWARE:NO /out:AocAsm.exe
if %errorlevel% neq 0 exit /b %errorlevel%

echo [SUCCESS] AocAsm.exe built successfully.
