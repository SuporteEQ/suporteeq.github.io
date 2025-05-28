@echo off



REM :: Notificacao via telegram
set bot_api="5778710873:AAEBZBIN_ZTBsRMJcdpEBdBu5rjiPlwqENU"
set bot_chat_id="183148731"

:: Obtém o tempo de inicializacao do sistema
REM for /f %%a in ('wmic os get lastbootuptime ^| find "."') do set LASTBOOT=%%a
for /f %%a in ('powershell -NoProfile -Command "(Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime.ToString('yyyyMMddHHmmss')"') do set LASTBOOT=%%a


:: Extrai a data e a hora de inicializacao
set LASTBOOT_DATE=%LASTBOOT:~0,8%
set LASTBOOT_TIME=%LASTBOOT:~8,6%

:: Converte a data e hora de inicializacao para um formato legivel
set LASTBOOT_DATE_FORMATTED=%LASTBOOT_DATE:~6,2%/%LASTBOOT_DATE:~4,2%/%LASTBOOT_DATE:~0,4%
set LASTBOOT_TIME_FORMATTED=%LASTBOOT_TIME:~0,2%:%LASTBOOT_TIME:~2,2%:%LASTBOOT_TIME:~4,2%


rem curl -s "https://api.telegram.org/bot%bot_api%/sendMessage?chat_id=%bot_chat_id%&disable_notification=true&text=Computer:%computername%|User:%username%|test"  > NUL 2>&1
rem curl -s "https://api.telegram.org/bot%bot_api%/sendMessage?chat_id=%bot_chat_id%&disable_notification=true&text=Computer:%computername%|User:%username%|Started:%LASTBOOT_DATE_FORMATTED%+%LASTBOOT_TIME_FORMATTED%"  > NUL 2>&1
curl -s "https://api.telegram.org/bot%bot_api%/sendMessage?chat_id=%bot_chat_id%&disable_notification=true&text=Computer:%computername%--Hello"  > NUL 2>&1
