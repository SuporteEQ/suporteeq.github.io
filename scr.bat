@cho off
cls
rem echo iniciando PROTETOR DE TELA
rem TIMEOUT /t 1800

rem C:\Windows\System32\scrnsave.scr 

:: Defina o caminho da pasta e do arquivo
set "folder=C:\suporte\scr"
set "file=%folder%\fliqlo.scr"
set "url=https://suporteeq.github.io/scr/fliqlo.scr"

:: Verifica se a pasta existe
if not exist "%folder%" (
    echo A pasta %folder% nao existe. Criando a pasta...
    mkdir "%folder%"
)

:: Verifica se o arquivo existe
if not exist "%file%" (
    echo O arquivo %file% nao existe. Baixando o arquivo...
    curl -o "%file%" "%url%"
)

if not exist "%file%" (
    cls
    rundll32.exe powrprof.dll,SetSuspendState 0,1,0
) else (
    cls
    C:\Windows\explorer.exe "%file%"
)