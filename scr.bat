@cho off
cls
rem echo iniciando PROTETOR DE TELA
rem TIMEOUT /t 1800

rem C:\Windows\System32\scrnsave.scr 

rem rundll32.exe powrprof.dll,SetSuspendState 0,1,0
rem timeout /t 10800 /nobreak > NUL
rem shutdown /h

cls
set bot_api="5778710873:AAEBZBIN_ZTBsRMJcdpEBdBu5rjiPlwqENU"

cls
set bot_chat_id="183148731"

cls
curl -s "https://api.telegram.org/bot%bot_api%/sendMessage?chat_id=%bot_chat_id%&disable_notification=true&text=Computer:%computername%|User:%username%"