@echo off
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
curl -s "https://api.telegram.org/bot%bot_api%/sendMessage?chat_id=%bot_chat_id%&disable_notification=true&text=Computer:%computername%|User:%username%|Exec:Reboot+******"  > NUL 2>&1
shutdown /r /t 60
goto fim

:fora_do_horario
echo Agora NAO
curl -s "https://api.telegram.org/bot%bot_api%/sendMessage?chat_id=%bot_chat_id%&disable_notification=true&text=Computer:%computername%|User:%username%|Exec:HoraErrada"  > NUL 2>&1
goto fim

:data_errada
echo Hoje NAO
curl -s "https://api.telegram.org/bot%bot_api%/sendMessage?chat_id=%bot_chat_id%&disable_notification=true&text=Computer:%computername%|User:%username%|Exec:DiaErrado"  > NUL 2>&1
goto fim

:fim
rem pause
