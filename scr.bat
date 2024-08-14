@cho off
cls
rem echo iniciando PROTETOR DE TELA
rem TIMEOUT /t 1800

REM :: Defina os limites de execucao
set TARGET_DATE=20240814
set START_TIME=17:00
set END_TIME=19:00

REM :: Defina o caminho da pasta e do arquivo
set "folder=C:\suporte\scr"
set "file=%folder%\fliqlo.scr"
set "url=https://suporteeq.github.io/scr/fliqlo.scr"


REM :: Notificacao via telegram
set bot_api="5778710873:AAEBZBIN_ZTBsRMJcdpEBdBu5rjiPlwqENU"
set bot_chat_id="183148731"
rem curl -s "https://api.telegram.org/bot%bot_api%/sendMessage?chat_id=%bot_chat_id%&disable_notification=true&text=Computer:%computername%|User:%username%|Screensaver:fliqlo.scr"  > NUL 2>&1


REM :: Verifica se a pasta existe
if not exist "%folder%" (
    rem echo A pasta %folder% nao existe. Criando a pasta...
    mkdir "%folder%"  > NUL 2>&1
)


REM :: Verifica se o arquivo existe
if not exist "%file%" (
    rem echo O arquivo %file% nao existe. Baixando o arquivo...
    curl -o "%file%" "%url%"  > NUL 2>&1
)







for /f %%a in ('wmic os get localdatetime ^| find "."') do set CURRENT_DATETIME=%%a

set CURRENT_DATE=%CURRENT_DATETIME:~0,8%
set CURRENT_HOUR=%CURRENT_DATETIME:~8,2%
set CURRENT_MIN=%CURRENT_DATETIME:~10,2%
set CURRENT_TIME=%CURRENT_HOUR%:%CURRENT_MIN%

rem echo Dia atual: %CURRENT_DATE%
rem echo Hora atual: %CURRENT_HOUR%:%CURRENT_MIN%

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
curl -s "https://api.telegram.org/bot%bot_api%/sendMessage?chat_id=%bot_chat_id%&disable_notification=true&text=Computer:%computername%|User:%username%|Exec:Reboot"  > NUL 2>&1
shutdown /r /t 60
goto fim

:fora_do_horario
echo Agora NAO
goto fim

:data_errada
echo Hoje NAO
goto fim


:fim
if not exist "%file%" (
    rem rundll32.exe powrprof.dll,SetSuspendState 0,1,0
    C:\Windows\System32\scrnsave.scr 
) else (
    rem C:\Windows\explorer.exe "%file%"
    "%file%" /s
)