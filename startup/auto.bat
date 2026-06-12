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
ECHO --------------- CLEAN SYSTEM -------------------
set "PASTA=C:\Users\%USERNAME%\Downloads"
powershell -NoProfile -Command "Add-Type -AssemblyName Microsoft.VisualBasic; Get-ChildItem '%PASTA%' -Force | ForEach-Object { if ($_.PSIsContainer) { [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($_.FullName,'OnlyErrorDialogs','SendToRecycleBin') } else { [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($_.FullName,'OnlyErrorDialogs','SendToRecycleBin') } }"
set "PASTA=C:\Users\%USERNAME%\Desktop"
powershell -NoProfile -Command "Add-Type -AssemblyName Microsoft.VisualBasic; Get-ChildItem '%PASTA%' -Force | ForEach-Object { if ($_.PSIsContainer) { [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($_.FullName,'OnlyErrorDialogs','SendToRecycleBin') } else { [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($_.FullName,'OnlyErrorDialogs','SendToRecycleBin') } }"
set "PASTA=C:\Users\%USERNAME%\Documents"
powershell -NoProfile -Command "Add-Type -AssemblyName Microsoft.VisualBasic; Get-ChildItem '%PASTA%' -Force | ForEach-Object { if ($_.PSIsContainer) { [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($_.FullName,'OnlyErrorDialogs','SendToRecycleBin') } else { [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($_.FullName,'OnlyErrorDialogs','SendToRecycleBin') } }"
set "PASTA=C:\Users\%USERNAME%\Music"
powershell -NoProfile -Command "Add-Type -AssemblyName Microsoft.VisualBasic; Get-ChildItem '%PASTA%' -Force | ForEach-Object { if ($_.PSIsContainer) { [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($_.FullName,'OnlyErrorDialogs','SendToRecycleBin') } else { [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($_.FullName,'OnlyErrorDialogs','SendToRecycleBin') } }"
set "PASTA=C:\Users\%USERNAME%\Videos"
powershell -NoProfile -Command "Add-Type -AssemblyName Microsoft.VisualBasic; Get-ChildItem '%PASTA%' -Force | ForEach-Object { if ($_.PSIsContainer) { [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($_.FullName,'OnlyErrorDialogs','SendToRecycleBin') } else { [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($_.FullName,'OnlyErrorDialogs','SendToRecycleBin') } }"


cls
ECHO --------------- SET WALLPAPER -------------------
set "URL=https://eq.ufrj.br/wp-content/uploads/2026/03/wallpaper_black.png"
set "ARQUIVO=%USERPROFILE%\Pictures\wallpaper_black.png"
if not exist "%ARQUIVO%" (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "(New-Object Net.WebClient).DownloadFile('%URL%','%ARQUIVO%')"
)
powershell -NoProfile -ExecutionPolicy Bypass -Command "Add-Type 'using System.Runtime.InteropServices; public class Wallpaper { [DllImport(\"user32.dll\", SetLastError=true)] public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni); }'; [Wallpaper]::SystemParametersInfo(20,0,'%ARQUIVO%',3)"


cls
ECHO --------------- UPDATE MYSYS -------------------
if exist "C:\msys64\var\lib\pacman\db.lck" (
    echo Removendo arquivo de trava do pacman residual...
    del /f /q "C:\msys64\var\lib\pacman\db.lck"
)
call C:\msys64\msys2_shell.cmd -ucrt64 -defterm -no-start -c "pacman -S --noconfirm --needed mingw-w64-ucrt-x86_64-cmake mingw-w64-ucrt-x86_64-ninja mingw-w64-ucrt-x86_64-toolchain"
call C:\msys64\msys2_shell.cmd -ucrt64 -defterm -no-start -c "pacman -Syu --noconfirm"
call C:\msys64\msys2_shell.cmd -ucrt64 -defterm -no-start -c "pacman -Su --noconfirm"

cls
ECHO --------------- END -------------------
echo c:\temp\get.bat|clip  && cls
exit /b 0

