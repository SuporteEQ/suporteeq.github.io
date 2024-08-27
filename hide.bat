@echo off
nircmd win min process cmd.exe
cls
mkdir c:\temp > NUL 2>&1
mkdir c:\suporte > NUL 2>&1

set "folder=C:\suporte"
set "file=%folder%\nircmdc.exe"
set "url=https://suporteeq.github.io/util/nircmdc.exe"

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

timeout /t 60
nircmd win min process cmd.exe
