@echo off
setlocal EnableExtensions

title EQ-UFRJ - Migracao Startup

set "GET_URL=http://suporteeq.github.io/startup/get.bat"
set "TEMP_DIR=C:\Temp"
set "LOG_FILE=%TEMP_DIR%\log.txt"
set "STARTUP_DIR=C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
set "GET_BAT=%STARTUP_DIR%\get.bat"
set "USER_STARTUP_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "USER_GET_BAT=%USER_STARTUP_DIR%\get.bat"
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
call :Log "Fallback usuario: %USER_GET_BAT%."
if exist "%USER_GET_BAT%" (
    for %%I in ("%USER_GET_BAT%") do if %%~zI GTR 0 (
        call :Log "Startup do usuario ja contem get.bat. Saindo sem repetir migracao comum."
        exit /b 0
    )
)

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
echo Tarefa agendada falhou. Tentando Startup do usuario atual...
call :Log "Tentando fallback no Startup do usuario atual."
call :InstallUserStartup
if not errorlevel 1 goto installed_user

set "LAST_ERROR=%ERRORLEVEL%"
call :Log "ERRO: fallback no Startup do usuario falhou com codigo %LAST_ERROR%."
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

:installed_user
call :Log "SUCESSO: get.bat instalado no Startup do usuario em %USER_GET_BAT%."
call :Log "AVISO: Startup comum continua inacessivel; call*.bat preservados."
del /f /q "%TMP_GET%" "%INSTALL_CMD%" >nul 2>&1
call :Log "Iniciando %USER_GET_BAT%."
start "" "%USER_GET_BAT%"
call :Log "Fim com sucesso via Startup do usuario."
exit /b 0

:InstallDirect
call :WriteInstallScript || exit /b 1
set "DIRECT_LOG=%TEMP_DIR%\install-direct-startup-%RANDOM%%RANDOM%.log"
call "%INSTALL_CMD%" > "%DIRECT_LOG%" 2>&1
set "DIRECT_RESULT=%ERRORLEVEL%"
call :AppendTempLog "%DIRECT_LOG%"
exit /b %DIRECT_RESULT%

:InstallWithPsExec
if not exist "%PSEXEC%" (
    echo PsExec64.exe nao encontrado em %PSEXEC%.
    call :Log "ERRO: PsExec64.exe nao encontrado em %PSEXEC%."
    exit /b 1
)

if not exist "%INSTALL_CMD%" (
    call :WriteInstallScript || exit /b 1
)

set "PSEXEC_LOG=%TEMP_DIR%\psexec-startup-%RANDOM%%RANDOM%.log"
"%PSEXEC%" -accepteula -nobanner -i -h -u "%ADMIN_USER%" -p "%ADMIN_PASS%" cmd.exe /c ""%INSTALL_CMD%"" > "%PSEXEC_LOG%" 2>&1
set "PSEXEC_RESULT=%ERRORLEVEL%"
call :AppendTempLog "%PSEXEC_LOG%"
exit /b %PSEXEC_RESULT%

:InstallWithScheduledTask
if not exist "%INSTALL_CMD%" (
    call :WriteInstallScript || exit /b 1
)

set "TASK_NAME=EQ-UFRJ-Startup-Migration-%RANDOM%%RANDOM%"
set "TASK_LOG=%TEMP_DIR%\schtasks-startup-%RANDOM%%RANDOM%.log"
call :Log "Criando tarefa agendada %TASK_NAME%."
schtasks /Create /TN "%TASK_NAME%" /TR "cmd.exe /c %INSTALL_CMD%" /SC ONCE /ST 23:59 /RL HIGHEST /RU "%ADMIN_USER%" /RP "%ADMIN_PASS%" /F > "%TASK_LOG%" 2>&1
set "TASK_RESULT=%ERRORLEVEL%"
if not "%TASK_RESULT%"=="0" (
    call :AppendTempLog "%TASK_LOG%"
    exit /b %TASK_RESULT%
)

call :Log "Executando tarefa agendada %TASK_NAME%."
schtasks /Run /TN "%TASK_NAME%" >> "%TASK_LOG%" 2>&1
set "TASK_RESULT=%ERRORLEVEL%"
if not "%TASK_RESULT%"=="0" (
    schtasks /Delete /TN "%TASK_NAME%" /F >> "%TASK_LOG%" 2>&1
    call :AppendTempLog "%TASK_LOG%"
    exit /b %TASK_RESULT%
)

call :WaitForGetBat
set "WAIT_RESULT=%ERRORLEVEL%"
schtasks /Delete /TN "%TASK_NAME%" /F >> "%TASK_LOG%" 2>&1
call :AppendTempLog "%TASK_LOG%"
exit /b %WAIT_RESULT%

:InstallUserStartup
if "%USER_STARTUP_DIR%"=="" (
    call :Log "ERRO: USER_STARTUP_DIR vazio."
    exit /b 1
)

set "USER_LOG=%TEMP_DIR%\user-startup-%RANDOM%%RANDOM%.log"
if not exist "%USER_STARTUP_DIR%" (
    mkdir "%USER_STARTUP_DIR%" > "%USER_LOG%" 2>&1
)

if not exist "%USER_STARTUP_DIR%" (
    call :AppendTempLog "%USER_LOG%"
    call :Log "ERRO: nao foi possivel criar/acessar %USER_STARTUP_DIR%."
    exit /b 1
)

copy /y "%TMP_GET%" "%USER_GET_BAT%" >> "%USER_LOG%" 2>&1
set "USER_RESULT=%ERRORLEVEL%"
call :AppendTempLog "%USER_LOG%"
if not "%USER_RESULT%"=="0" exit /b %USER_RESULT%

if not exist "%USER_GET_BAT%" (
    call :Log "ERRO: %USER_GET_BAT% nao foi encontrado apos copia."
    exit /b 1
)

for %%I in ("%USER_GET_BAT%") do if %%~zI GTR 0 exit /b 0
call :Log "ERRO: %USER_GET_BAT% existe, mas esta vazio."
exit /b 1

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

:AppendTempLog
if "%~1"=="" exit /b 0
if not exist "%~1" exit /b 0
for %%I in ("%~1") do if %%~zI GTR 0 (
    >> "%LOG_FILE%" echo [%date% %time%] Saida de %%~nxI:
    type "%~1" >> "%LOG_FILE%" 2>nul
)
del /f /q "%~1" >nul 2>&1
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
