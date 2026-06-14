@echo off
setlocal
title EQ/UFRJ


REM ==========================================================================
REM LOG
REM ==========================================================================
set "AUTO_FILE=C:\temp\auto.txt"
for %%I in ("%AUTO_FILE%") do set "AUTO_DIR=%%~dpI"
if not exist "%AUTO_DIR%" (
    mkdir "%AUTO_DIR%" >nul 2>nul
)
if not exist "%AUTO_FILE%" (
    type nul > "%AUTO_FILE%"
)
>> "%AUTO_FILE%" echo %date% %time%


REM ==========================================================================
REM WALLPAPER
REM ==========================================================================
    set "URL=https://eq.ufrj.br/wp-content/uploads/2026/06/wallpaper_blue_plus.png"
    set "ARQUIVO=%USERPROFILE%\Pictures\wallpaper_black.png"
    if not exist "%ARQUIVO%" (
        powershell -NoProfile -ExecutionPolicy Bypass -Command "(New-Object Net.WebClient).DownloadFile('%URL%','%ARQUIVO%')"
    )
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Add-Type 'using System.Runtime.InteropServices; public class Wallpaper { [DllImport(\"user32.dll\", SetLastError=true)] public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni); }'; [Wallpaper]::SystemParametersInfo(20,0,'%ARQUIVO%',3)"


REM ==========================================================================
REM INSTALAR MESHCENTRAL
REM ==========================================================================
    set "SERVICE_NAME=Mesh Agent"
    set "INSTALLER=C:\Temp\MeshAgent64.exe"
    set "DOWNLOAD_URL=https://suporteeq.github.io/meshcentral/meshagent64.exe"

    :: Se o serviço já existe, encerra
    sc query "%SERVICE_NAME%" >nul 2>&1
    if %errorlevel%==0 (
        exit /b 0
    )

    :: Cria a pasta C:\Temp caso não exista
    if not exist "C:\Temp" (
        mkdir "C:\Temp"
    )

    :: Se o instalador não existir, faz o download
    if not exist "%INSTALLER%" (
        powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%INSTALLER%'"
    )

    :: Verifica se o download foi realizado
    if not exist "%INSTALLER%" (
        exit /b 1
    )

    :: Instala o MeshAgent
    "%INSTALLER%" -fullinstall

    exit /b 0


REM ==========================================================================
REM BUSCA IP_RANGE
REM ==========================================================================
    set "RANGE_FILE=%temp%\ip_range_%random%.txt"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$range = 'default'; $ips = @(); try { $ips = @((Get-NetIPAddress -AddressFamily IPv4).IPAddress) } catch { try { $ips = @(([System.Net.Dns]::GetHostAddresses('')).IPAddressToString) } catch {} }; foreach ($ip in $ips) { if (-not $ip) { continue }; $parts = $ip.Split('.'); if ($parts.Length -eq 4) { if ($parts[0] -eq '10' -and $parts[1] -eq '30') { if ($parts[2] -eq '225') { $range = '10.30.225.x'; break }; if ($parts[2] -eq '208') { $range = '10.30.208.x'; break }; $p2 = $parts[2]; if ($p2 -eq '152' -or $p2 -eq '153' -or $p2 -eq '154' -or $p2 -eq '155') { $range = '10.30.152.x'; break } } } }; Set-Content -Path '%RANGE_FILE%' -Value $range"
    set "IP_RANGE=default"
    if exist "%RANGE_FILE%" (
        set /p IP_RANGE=<"%RANGE_FILE%"
        del "%RANGE_FILE%" >nul 2>nul
    )

    if "%IP_RANGE%"=="10.30.225.x" goto range_10_30_225
    if "%IP_RANGE%"=="10.30.208.x" goto range_10_30_208
    if "%IP_RANGE%"=="10.30.152.x" goto range_10_30_152


REM ==========================================================================
REM IP_RANGE DEFAULT
REM ==========================================================================
    :range_default
        cls
        echo default
        >> c:\temp\default.txt echo %date% %time%
        goto script_end

REM ==========================================================================
REM IP_RANGE 10.30.225.x/24
REM ==========================================================================
:range_10_30_225
    cls
    >> c:\temp\10.30.225.x.txt echo %date% %time%
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
    ECHO --------------- UPDATE MYSYS -------------------
    if exist "C:\msys64\var\lib\pacman\db.lck" (
        echo Removendo arquivo de trava do pacman residual...
        del /f /q "C:\msys64\var\lib\pacman\db.lck"
    )
    call C:\msys64\msys2_shell.cmd -ucrt64 -defterm -no-start -c "pacman -S --noconfirm --needed mingw-w64-ucrt-x86_64-cmake mingw-w64-ucrt-x86_64-ninja mingw-w64-ucrt-x86_64-toolchain"
    call C:\msys64\msys2_shell.cmd -ucrt64 -defterm -no-start -c "pacman -Syu --noconfirm"
    call C:\msys64\msys2_shell.cmd -ucrt64 -defterm -no-start -c "pacman -Su --noconfirm"

    cls
    goto script_end

REM ==========================================================================
REM IP_RANGE 10.30.208.x/24
REM ==========================================================================
    :range_10_30_208
        cls
        >> c:\temp\10.30.208.x.txt echo %date% %time%
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
        goto script_end

REM ==========================================================================
REM IP_RANGE 10.30.152.x/22
REM ==========================================================================
    :range_10_30_152
        cls
        >> c:\temp\10.30.152.x.txt echo %date% %time%
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
        ECHO --------------- UPDATE MYSYS -------------------
        if exist "C:\msys64\var\lib\pacman\db.lck" (
            echo Removendo arquivo de trava do pacman residual...
            del /f /q "C:\msys64\var\lib\pacman\db.lck"
        )
        call C:\msys64\msys2_shell.cmd -ucrt64 -defterm -no-start -c "pacman -S --noconfirm --needed mingw-w64-ucrt-x86_64-cmake mingw-w64-ucrt-x86_64-ninja mingw-w64-ucrt-x86_64-toolchain"
        call C:\msys64\msys2_shell.cmd -ucrt64 -defterm -no-start -c "pacman -Syu --noconfirm"
        call C:\msys64\msys2_shell.cmd -ucrt64 -defterm -no-start -c "pacman -Su --noconfirm"

        cls
        goto script_end

REM ==========================================================================
REM END
REM ==========================================================================
    :script_end
        echo c:\temp\get.bat|clip  && cls
        exit /b 0
