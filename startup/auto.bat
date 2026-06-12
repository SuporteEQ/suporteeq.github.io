@echo off
setlocal

title EQ/UFRJ

set "AUTO_FILE=C:\temp\auto.txt"

for %%I in ("%AUTO_FILE%") do set "AUTO_DIR=%%~dpI"

if not exist "%AUTO_DIR%" (
    mkdir "%AUTO_DIR%" >nul 2>nul
)

if not exist "%AUTO_FILE%" (
    type nul > "%AUTO_FILE%"
)

>> "%AUTO_FILE%" echo %date% %time%

REM call "%~dp0manual.bat"

cls
echo c:\temp\get.bat|clip  && cls

if exist "C:\msys64\var\lib\pacman\db.lck" (
    echo Removendo arquivo de trava do pacman residual...
    del /f /q "C:\msys64\var\lib\pacman\db.lck"
)


cls
ECHO --------------- UPDATE MYSYS 1/3 -------------------
call C:\msys64\msys2_shell.cmd -ucrt64 -defterm -no-start -c "pacman -S --noconfirm --needed mingw-w64-ucrt-x86_64-cmake mingw-w64-ucrt-x86_64-ninja mingw-w64-ucrt-x86_64-toolchain"

cls
ECHO --------------- UPDATE MYSYS 3/3 -------------------
call C:\msys64\msys2_shell.cmd -ucrt64 -defterm -no-start -c "pacman -Syu --noconfirm"

cls
ECHO --------------- UPDATE MYSYS 3/3 -------------------
call C:\msys64\msys2_shell.cmd -ucrt64 -defterm -no-start -c "pacman -Su --noconfirm"

cls
exit /b 0

