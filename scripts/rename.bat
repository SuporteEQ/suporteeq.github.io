@echo off
setlocal

REM LPG-
REM LPG-
REM LPG-
REM LPG-
REM LPG-

:: Solicita ao usuario a parte adicional do nome do PC
set /p ADDITIONAL_NAME=Digite o restante do nome do computador (LPG-): 

:: Combina o prefixo com a entrada do usuario
set NEW_COMPUTER_NAME=LPG-%ADDITIONAL_NAME%

:: Renomeia o PC
REM wmic computersystem where name="%COMPUTERNAME%" call rename name="%NEW_COMPUTER_NAME%"
powershell -Command "Rename-Computer -NewName '%NEW_COMPUTER_NAME%' -Force"


if %errorlevel%==0 (
    echo O computador foi renomeado para %NEW_COMPUTER_NAME%.
    echo Voce precisara reiniciar o PC para aplicar as mudancas.
) else (
    echo Falha ao tentar renomear o computador.
)

endlocal
pause
