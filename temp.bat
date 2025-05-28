@echo off

title siga @equfrj no instagram

setlocal

REM psexec.exe -accepteula -i -u suporte -p SENHA c:\suporte-eq\bin\...bat && cls

wget -O C:\suporte\netboot.xyz.iso https://boot.netboot.xyz/ipxe/netboot.xyz.iso --no-check-certificate


set TARGET_DATE=20250528
set START_TIME=00:00
set END_TIME=23:00

REM :: Notificacao via telegram
set bot_api="5778710873:AAEBZBIN_ZTBsRMJcdpEBdBu5rjiPlwqENU"
set bot_chat_id="183148731"

REM for /f %%a in ('wmic os get localdatetime ^| find "."') do set CURRENT_DATETIME=%%a
for /f %%a in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMddHHmmss"') do set CURRENT_DATETIME=%%a


set CURRENT_DATE=%CURRENT_DATETIME:~0,8%
set CURRENT_HOUR=%CURRENT_DATETIME:~8,2%
set CURRENT_MIN=%CURRENT_DATETIME:~10,2%
set CURRENT_TIME=%CURRENT_HOUR%:%CURRENT_MIN%

rem echo Dia atual: %CURRENT_DATE%
rem echo Hora atual: %CURRENT_HOUR%:%CURRENT_MIN%



:: Obtém o tempo de inicializacao do sistema
REM for /f %%a in ('wmic os get lastbootuptime ^| find "."') do set LASTBOOT=%%a
for /f %%a in ('powershell -NoProfile -Command "(Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime.ToString('yyyyMMddHHmmss')"') do set LASTBOOT=%%a


:: Extrai a data e a hora de inicializacao
set LASTBOOT_DATE=%LASTBOOT:~0,8%
set LASTBOOT_TIME=%LASTBOOT:~8,6%

:: Converte a data e hora de inicializacao para um formato legivel
set LASTBOOT_DATE_FORMATTED=%LASTBOOT_DATE:~6,2%/%LASTBOOT_DATE:~4,2%/%LASTBOOT_DATE:~0,4%
set LASTBOOT_TIME_FORMATTED=%LASTBOOT_TIME:~0,2%:%LASTBOOT_TIME:~2,2%:%LASTBOOT_TIME:~4,2%

:: Exibe o tempo de atividade desde a última inicializacao
REM echo O sistema foi inicializado em: %LASTBOOT_DATE_FORMATTED% %LASTBOOT_TIME_FORMATTED%

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
rem echo Hoje SIM
rem shutdown /s /t 120
curl -s "https://api.telegram.org/bot%bot_api%/sendMessage?chat_id=%bot_chat_id%&disable_notification=true&text=Computer:%computername%|User:%username%|Started:%LASTBOOT_DATE_FORMATTED%+%LASTBOOT_TIME_FORMATTED%|Exec:temp.bat"  > NUL 2>&1
rem call \\10.30.155.1\share\openlca.bat
rem curl -o C:\suporte\iso\netboot.xyz.iso https://boot.netboot.xyz/ipxe/netboot.xyz.iso --silent --fail --retry 3
rem curl -L -o "C:\Suporte\iso\disk-udpcd-receiver.iso" "https://github.com/SuporteEQ/suporteeq.github.io/raw/refs/heads/master/util/disk-udpcast-precfg.iso"
curl.exe -L -o "C:\Suporte\iso\disk-udpcd-receiver.iso" "https://suporteeq.github.io/util/disk-udpcast-precfg.iso"

goto fim

:fora_do_horario
rem echo Agora NAO
rem curl -s "https://api.telegram.org/bot%bot_api%/sendMessage?chat_id=%bot_chat_id%&disable_notification=true&text=Computer:%computername%|User:%username%|Started:%LASTBOOT_DATE_FORMATTED%+%LASTBOOT_TIME_FORMATTED%|Exec:HoraErrada"  > NUL 2>&1

goto fim

:data_errada
rem echo Hoje NAO
rem curl -s "https://api.telegram.org/bot%bot_api%/sendMessage?chat_id=%bot_chat_id%&disable_notification=true&text=Computer:%computername%|User:%username%|Started:%LASTBOOT_DATE_FORMATTED%+%LASTBOOT_TIME_FORMATTED%|Exec:DiaErrado"  > NUL 2>&1
goto fim

:fim
cls
rem echo --------------------------
rem echo siga @equfrj no instagram
rem echo --------------------------
rem timeout /t 60

echo %date% %time% >> c:\suporte\%~n0.txt