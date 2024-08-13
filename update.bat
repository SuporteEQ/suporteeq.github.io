@echo off
:: Verifica se o script está sendo executado com privilégios de administrador
:: Fonte: https://stackoverflow.com/a/296616

:: Se o script não estiver sendo executado com privilégios de administrador, reexecuta o script como administrador
:: para obter os privilégios necessários
if not "%1"=="ELEV" (
    setlocal EnableDelayedExpansion
    set "batchPath=%~f0"
    set "batchArgs=%*"
    powershell -Command "Start-Process cmd -ArgumentList '/c ""!batchPath! ELEV !batchArgs!""' -Verb RunAs"
    exit /b
)

:: Apaga arquivos especificados na pasta StartUp
echo Deletando arquivos da pasta StartUp...

del /f /q "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\ApagarDownloads.bat"
del /f /q "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\EQ1.bat"
del /f /q "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\EQ2.bat"
del /f /q "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\startup.bat"
del /f /q "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\run.bat"

:: Baixa o novo arquivo na pasta StartUp
echo Baixando novo arquivo para a pasta StartUp...

powershell -Command "Invoke-WebRequest -Uri 'https://suporteeq.github.io/call_lpg.bat' -OutFile 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\call_lpg.bat'"

:: Baixa e substitui arquivos na pasta System32
echo Baixando e substituindo arquivos na pasta System32...

powershell -Command "Invoke-WebRequest -Uri 'https://suporteeq.github.io/eq.cmd' -OutFile 'C:\Windows\System32\eq.cmd'"
powershell -Command "Invoke-WebRequest -Uri 'https://suporteeq.github.io/CMS.cmd' -OutFile 'C:\Windows\System32\CMS.cmd'"


echo Concluído.
pause
echo "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\call_lpg.bat"|clip
call "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\call_lpg.bat"
call "C:\Windows\System32\eq.cmd"
call "C:\Windows\System32\CMS.cmd"
pause
pause
shutdown /r /t 10