@echo off

setlocal

REM psexec.exe -accepteula -i -u suporte -p SENHA c:\suporte-eq\bin\...bat && cls

set TARGET_DATE=20240814
set START_TIME=17:00
set END_TIME=21:00

REM :: Notificacao via telegram
set bot_api="5778710873:AAEBZBIN_ZTBsRMJcdpEBdBu5rjiPlwqENU"
set bot_chat_id="183148731"

for /f %%a in ('wmic os get localdatetime ^| find "."') do set CURRENT_DATETIME=%%a

set CURRENT_DATE=%CURRENT_DATETIME:~0,8%
set CURRENT_HOUR=%CURRENT_DATETIME:~8,2%
set CURRENT_MIN=%CURRENT_DATETIME:~10,2%
set CURRENT_TIME=%CURRENT_HOUR%:%CURRENT_MIN%

echo Dia atual: %CURRENT_DATE%
echo Hora atual: %CURRENT_HOUR%:%CURRENT_MIN%



:: Obtém o tempo de inicializacao do sistema
for /f %%a in ('wmic os get lastbootuptime ^| find "."') do set LASTBOOT=%%a

:: Extrai a data e a hora de inicializacao
set LASTBOOT_DATE=%LASTBOOT:~0,8%
set LASTBOOT_TIME=%LASTBOOT:~8,6%

:: Converte a data e hora de inicializacao para um formato legivel
set LASTBOOT_DATE_FORMATTED=%LASTBOOT_DATE:~6,2%/%LASTBOOT_DATE:~4,2%/%LASTBOOT_DATE:~0,4%
set LASTBOOT_TIME_FORMATTED=%LASTBOOT_TIME:~0,2%:%LASTBOOT_TIME:~2,2%:%LASTBOOT_TIME:~4,2%

:: Exibe o tempo de atividade desde a última inicializacao
echo O sistema foi inicializado em: %LASTBOOT_DATE_FORMATTED% %LASTBOOT_TIME_FORMATTED%

:: Usa PowerShell para calcular o uptime
for /f %%u in ('powershell -command "(get-date) - (gcim Win32_OperatingSystem).LastBootUpTime"') do set UPTIME=%%u




if "%CURRENT_DATE%"=="%TARGET_DATE%" (
    if "%CURRENT_TIME%" GEQ "%START_TIME%" if "%CURRENT_TIME%" LEQ "%END_TIME%" (
        goto exec_comando
    ) else (
        goto fora_do_horario
    )
) else (
    goto data_errada
)


:exec_comando
:: Coloque aqui o comando que você deseja executar
echo Hoje SIM
curl -s "https://api.telegram.org/bot%bot_api%/sendMessage?chat_id=%bot_chat_id%&disable_notification=true&text=Computer:%computername%|User:%username%|Uptime:%UPTIME%|Exec:Reboot*ate*21h"  > NUL 2>&1
goto fim

:fora_do_horario
echo Agora NAO
curl -s "https://api.telegram.org/bot%bot_api%/sendMessage?chat_id=%bot_chat_id%&disable_notification=true&text=Computer:%computername%|User:%username%|Uptime:%UPTIME%|Exec:HoraErrada"  > NUL 2>&1
goto fim

:data_errada
echo Hoje NAO
curl -s "https://api.telegram.org/bot%bot_api%/sendMessage?chat_id=%bot_chat_id%&disable_notification=true&text=Computer:%computername%|User:%username%|Uptime:%UPTIME%|Exec:DiaErrado"  > NUL 2>&1
goto fim

:fim
rem pause
