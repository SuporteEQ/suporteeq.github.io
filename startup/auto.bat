@echo off
setlocal

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

exit /b 0
