@cho off
cls
rem echo iniciando PROTETOR DE TELA
rem TIMEOUT /t 1800


REM :: Defina o caminho da pasta e do arquivo
set "folder=C:\suporte\scr"
set "file=%folder%\fliqlo.scr"
set "url=https://suporteeq.github.io/scr/fliqlo.scr"


REM :: Notificacao via telegram
set bot_api="5778710873:AAEBZBIN_ZTBsRMJcdpEBdBu5rjiPlwqENU"
set bot_chat_id="183148731"
curl -s "https://api.telegram.org/bot%bot_api%/sendMessage?chat_id=%bot_chat_id%&disable_notification=true&text=Computer:%computername%|User:%username%|Screensaver:fliqlo.scr"  > NUL 2>&1


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


REM :: Verifica se o arquivo existe e executa
if not exist "%file%" (
    rem rundll32.exe powrprof.dll,SetSuspendState 0,1,0
    C:\Windows\System32\scrnsave.scr 
) else (
    rem C:\Windows\explorer.exe "%file%"
    "%file%" /s
)