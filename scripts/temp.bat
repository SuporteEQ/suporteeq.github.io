@echo off
title siga @equfrj no instagram
setlocal

rem Defina aqui o intervalo de datas e horários
set START_DATE=20250528
set END_DATE=20250628
set START_TIME=00:01
set END_TIME=23:59

set bot_api=5778710873:AAEBZBIN_ZTBsRMJcdpEBdBu5rjiPlwqENU
set bot_chat_id=183148731

for /f %%a in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMddHHmmss"') do set CURRENT_DATETIME=%%a
set CURRENT_DATE=%CURRENT_DATETIME:~0,8%
set CURRENT_TIME=%CURRENT_DATETIME:~8,2%:%CURRENT_DATETIME:~10,2%

for /f %%a in ('powershell -NoProfile -Command "(Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime.ToString('yyyyMMddHHmmss')"') do set LASTBOOT=%%a
set LASTBOOT_DATE=%LASTBOOT:~0,8%
set LASTBOOT_TIME=%LASTBOOT:~8,2%:%LASTBOOT:~10,2%:%LASTBOOT:~12,2%

set EXECUTE=NOT

rem Verifica se a data atual está entre a data inicial e final (inclusive)
if "%CURRENT_DATE%" GEQ "%START_DATE%" if "%CURRENT_DATE%" LEQ "%END_DATE%" (
    rem Verifica se a hora atual está entre hora inicial e final (inclusive)
    if "%CURRENT_TIME%" GEQ "%START_TIME%" if "%CURRENT_TIME%" LEQ "%END_TIME%" (
        set EXECUTE=YES
    )
)

if "%EXECUTE%"=="YES" (
    echo Executando comando...
    start /b "" curl.exe -L -o "C:\Suporte\iso\disk-udpcd-receiver.iso" "https://suporteeq.github.io/util/disk-udpcast-precfg.iso" >nul 2>&1
    start /b "" curl.exe -L -o "C:\suporte\netboot.xyz.iso" "https://boot.netboot.xyz/ipxe/netboot.xyz.iso"  >nul 2>&1
    start /b "" curl.exe -L -o "C:\suporte\iso\netboot.xyz.iso" "https://boot.netboot.xyz/ipxe/netboot.xyz.iso"  >nul 2>&1
    curl -s "https://api.telegram.org/bot%bot_api%/sendMessage?chat_id=%bot_chat_id%&disable_notification=true&text=Computer:%computername%|User:%username%|Started:%LASTBOOT_DATE%+%LASTBOOT_TIME%|Exec:done" >NUL 2>&1
) else (
    echo Fora do intervalo de data ou horario
    curl -s "https://api.telegram.org/bot%bot_api%/sendMessage?chat_id=%bot_chat_id%&disable_notification=true&text=Computer:%computername%|User:%username%|Started:%LASTBOOT_DATE%+%LASTBOOT_TIME%|Exec:not_executed" >NUL 2>&1
)

rem ALWAYS
@REM start /b "" curl.exe -L -o "C:\Suporte\iso\disk-udpcd-receiver.iso" "https://suporteeq.github.io/util/disk-udpcast-precfg.iso" >nul 2>&1
@REM start /b "" curl.exe -L -o "C:\suporte\netboot.xyz.iso" "https://boot.netboot.xyz/ipxe/netboot.xyz.iso"  >nul 2>&1
@REM start /b "" curl.exe -L -o "C:\suporte\iso\netboot.xyz.iso" "https://boot.netboot.xyz/ipxe/netboot.xyz.iso"  >nul 2>&1


echo %date% %time% >> c:\suporte\%~n0.txt
pause
cls