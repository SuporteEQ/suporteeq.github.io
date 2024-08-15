@echo off
setlocal

REM Obtém o uptime do sistema
for /f "tokens=1-8 delims= " %%a in ('net statistics workstation ^| find "estat"') do (
    set UPTIME_DATE=%%c
    set UPTIME_TIME=%%e
)

REM Exibe o uptime
echo O sistema está em funcionamento desde: %UPTIME_DATE% %UPTIME_TIME%

endlocal

pause