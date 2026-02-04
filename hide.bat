@echo off
@REM nircmd win min process cmd.exe
@REM cls
@REM mkdir c:\temp > NUL 2>&1
@REM mkdir c:\suporte > NUL 2>&1

@REM set "folder=C:\suporte"
@REM set "file=%folder%\nircmdc.exe"
@REM set "url=https://suporteeq.github.io/util/nircmdc.exe"

@REM REM :: Verifica se a pasta existe
@REM if not exist "%folder%" (
@REM     rem echo A pasta %folder% nao existe. Criando a pasta...
@REM     mkdir "%folder%"  > NUL 2>&1
@REM )
@REM REM :: Verifica se o arquivo existe
@REM if not exist "%file%" (
@REM     rem echo O arquivo %file% nao existe. Baixando o arquivo...
@REM     curl -o "%file%" "%url%"  > NUL 2>&1
@REM )

@REM nircmd win min process cmd.exe
@REM echo %date% %time% >> c:\suporte\%~n0.txt
