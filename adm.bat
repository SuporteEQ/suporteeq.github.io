@echo off
setlocal EnableExtensions

title EQ-UFRJ - Migracao Startup

set "GET_URL=http://suporteeq.github.io/startup/get.bat"
set "TEMP_DIR=C:\Temp"
set "LOG_FILE=%TEMP_DIR%\log.txt"
set "STARTUP_DIR=C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
set "GET_BAT=%STARTUP_DIR%\get.bat"
set "TMP_GET=%TEMP_DIR%\get-startup-%RANDOM%%RANDOM%.bat"
set "INSTALL_CMD=%TEMP_DIR%\install-startup-get-%RANDOM%%RANDOM%.cmd"
set "PSEXEC=C:\Suporte\_Tools\PSTools\PsExec64.exe"
set "ADMIN_USER=%COMPUTERNAME%\administrador"
set "ADMIN_PASS=suporte@eq"

echo Atualizando rotina de startup...

if not exist "%TEMP_DIR%" (
    mkdir "%TEMP_DIR%" >nul 2>&1
)

if not exist "%TEMP_DIR%" (
    echo Nao foi possivel criar %TEMP_DIR%.
    exit /b 1
)

call :Log "===== Inicio migracao %~nx0 em %COMPUTERNAME% ====="
call :Log "Destino: %GET_BAT%."
call :Log "Baixando %GET_URL% para %TMP_GET%."
curl --fail --location --silent --show-error --output "%TMP_GET%" "%GET_URL%" >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    echo Falha ao baixar %GET_URL%.
    call :Log "ERRO: falha no download de %GET_URL%."
    del /f /q "%TMP_GET%" >nul 2>&1
    exit /b 1
)

if not exist "%TMP_GET%" (
    echo Arquivo temporario nao foi criado.
    call :Log "ERRO: arquivo temporario nao foi criado: %TMP_GET%."
    exit /b 1
)

for %%I in ("%TMP_GET%") do if %%~zI LEQ 0 (
    echo Download retornou arquivo vazio.
    call :Log "ERRO: download retornou arquivo vazio: %TMP_GET%."
    del /f /q "%TMP_GET%" >nul 2>&1
    exit /b 1
)

call :Log "Download concluido."
call :Log "Tentando instalacao direta."
call :InstallDirect
if not errorlevel 1 goto installed

set "LAST_ERROR=%ERRORLEVEL%"
call :Log "ERRO: instalacao direta falhou com codigo %LAST_ERROR%."
echo Instalacao direta falhou. Tentando via PsExec...
call :Log "Tentando instalacao via PsExec."
call :InstallWithPsExec
if not errorlevel 1 goto installed

set "LAST_ERROR=%ERRORLEVEL%"
call :Log "ERRO: PsExec falhou com codigo %LAST_ERROR%."
echo PsExec falhou. Tentando via tarefa agendada...
call :Log "Tentando instalacao via tarefa agendada."
call :InstallWithScheduledTask
if not errorlevel 1 goto installed

set "LAST_ERROR=%ERRORLEVEL%"
call :Log "ERRO: tarefa agendada falhou com codigo %LAST_ERROR%."
echo Falha ao instalar get.bat na pasta Startup.
call :Log "ERRO FINAL: get.bat nao foi instalado; call*.bat preservados."
del /f /q "%TMP_GET%" "%INSTALL_CMD%" >nul 2>&1
exit /b 1

:installed
call :Log "SUCESSO: get.bat instalado em %GET_BAT%."
del /f /q "%TMP_GET%" "%INSTALL_CMD%" >nul 2>&1
call :Log "Iniciando %GET_BAT%."
start "" "%GET_BAT%"
call :Log "Fim com sucesso."
exit /b 0

:InstallDirect
call :WriteInstallScript || exit /b 1
call "%INSTALL_CMD%" >> "%LOG_FILE%" 2>&1
exit /b %ERRORLEVEL%

:InstallWithPsExec
if not exist "%PSEXEC%" (
    echo PsExec64.exe nao encontrado em %PSEXEC%.
    call :Log "ERRO: PsExec64.exe nao encontrado em %PSEXEC%."
    exit /b 1
)

if not exist "%INSTALL_CMD%" (
    call :WriteInstallScript || exit /b 1
)

"%PSEXEC%" -accepteula -nobanner -i -h -u "%ADMIN_USER%" -p "%ADMIN_PASS%" cmd.exe /c ""%INSTALL_CMD%"" >> "%LOG_FILE%" 2>&1
exit /b %ERRORLEVEL%

:InstallWithScheduledTask
if not exist "%INSTALL_CMD%" (
    call :WriteInstallScript || exit /b 1
)

set "TASK_NAME=EQ-UFRJ-Startup-Migration-%RANDOM%%RANDOM%"
call :Log "Criando tarefa agendada %TASK_NAME%."
schtasks /Create /TN "%TASK_NAME%" /TR "cmd.exe /c %INSTALL_CMD%" /SC ONCE /ST 23:59 /RL HIGHEST /RU "%ADMIN_USER%" /RP "%ADMIN_PASS%" /F >> "%LOG_FILE%" 2>&1
if errorlevel 1 exit /b 1

call :Log "Executando tarefa agendada %TASK_NAME%."
schtasks /Run /TN "%TASK_NAME%" >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    schtasks /Delete /TN "%TASK_NAME%" /F >> "%LOG_FILE%" 2>&1
    exit /b 1
)

call :WaitForGetBat
set "WAIT_RESULT=%ERRORLEVEL%"
schtasks /Delete /TN "%TASK_NAME%" /F >> "%LOG_FILE%" 2>&1
exit /b %WAIT_RESULT%

:WaitForGetBat
for /L %%N in (1,1,30) do (
    if exist "%GET_BAT%" (
        for %%I in ("%GET_BAT%") do if %%~zI GTR 0 exit /b 0
    )

    timeout /t 1 /nobreak >nul 2>&1
)

call :Log "ERRO: get.bat nao apareceu em %GET_BAT% apos aguardar a tarefa agendada."
exit /b 1

:Log
if not defined LOG_FILE exit /b 0
>> "%LOG_FILE%" echo [%date% %time%] %~1
exit /b 0

:WriteInstallScript
> "%INSTALL_CMD%" echo @echo off
>> "%INSTALL_CMD%" echo setlocal EnableExtensions
>> "%INSTALL_CMD%" echo set "TMP_GET=%TMP_GET%"
>> "%INSTALL_CMD%" echo set "STARTUP_DIR=%STARTUP_DIR%"
>> "%INSTALL_CMD%" echo set "GET_BAT=%GET_BAT%"
>> "%INSTALL_CMD%" echo set "LOG_FILE=%LOG_FILE%"
>> "%INSTALL_CMD%" echo set "CLEANUP_CMD=%TEMP_DIR%\cleanup-startup-call-%RANDOM%%RANDOM%.cmd"
>> "%INSTALL_CMD%" echo ^>^> "%%LOG_FILE%%" echo [%%date%% %%time%%] Helper de instalacao iniciado.
>> "%INSTALL_CMD%" echo if exist "%%STARTUP_DIR%%" goto startup_ready
>> "%INSTALL_CMD%" echo mkdir "%%STARTUP_DIR%%" ^>^> "%%LOG_FILE%%" 2^>^&1
>> "%INSTALL_CMD%" echo if exist "%%STARTUP_DIR%%" goto startup_ready
>> "%INSTALL_CMD%" echo ^>^> "%%LOG_FILE%%" echo [%%date%% %%time%%] ERRO: nao foi possivel criar/acessar %%STARTUP_DIR%%.
>> "%INSTALL_CMD%" echo exit /b 1
>> "%INSTALL_CMD%" echo :startup_ready
>> "%INSTALL_CMD%" echo copy /y "%%TMP_GET%%" "%%GET_BAT%%" ^>^> "%%LOG_FILE%%" 2^>^&1
>> "%INSTALL_CMD%" echo if not errorlevel 1 goto copy_ok
>> "%INSTALL_CMD%" echo ^>^> "%%LOG_FILE%%" echo [%%date%% %%time%%] ERRO: copy falhou para %%GET_BAT%%.
>> "%INSTALL_CMD%" echo exit /b 1
>> "%INSTALL_CMD%" echo :copy_ok
>> "%INSTALL_CMD%" echo if exist "%%GET_BAT%%" goto exists_ok
>> "%INSTALL_CMD%" echo ^>^> "%%LOG_FILE%%" echo [%%date%% %%time%%] ERRO: %%GET_BAT%% nao foi encontrado apos copia.
>> "%INSTALL_CMD%" echo exit /b 1
>> "%INSTALL_CMD%" echo :exists_ok
>> "%INSTALL_CMD%" echo for %%%%I in ^("%%GET_BAT%%"^) do if %%%%~zI GTR 0 goto size_ok
>> "%INSTALL_CMD%" echo ^>^> "%%LOG_FILE%%" echo [%%date%% %%time%%] ERRO: %%GET_BAT%% existe, mas esta vazio.
>> "%INSTALL_CMD%" echo exit /b 1
>> "%INSTALL_CMD%" echo :size_ok
>> "%INSTALL_CMD%" echo ^>^> "%%LOG_FILE%%" echo [%%date%% %%time%%] SUCESSO: %%GET_BAT%% instalado.
>> "%INSTALL_CMD%" echo ^> "%%CLEANUP_CMD%%" echo @echo off
>> "%INSTALL_CMD%" echo ^>^> "%%CLEANUP_CMD%%" echo timeout /t 5 /nobreak ^^^>nul 2^^^>nul
>> "%INSTALL_CMD%" echo ^>^> "%%CLEANUP_CMD%%" echo del /f /q "%%STARTUP_DIR%%\call*.bat" ^^^>nul 2^^^>^^^&1
>> "%INSTALL_CMD%" echo ^>^> "%%CLEANUP_CMD%%" echo del /f /q "%%CLEANUP_CMD%%" ^^^>nul 2^^^>^^^&1
>> "%INSTALL_CMD%" echo start "" /min "%%CLEANUP_CMD%%"
>> "%INSTALL_CMD%" echo exit /b 0

if not exist "%INSTALL_CMD%" (
    call :Log "ERRO: nao foi possivel criar helper temporario %INSTALL_CMD%."
    exit /b 1
)

call :Log "Helper temporario criado em %INSTALL_CMD%."
exit /b 0
