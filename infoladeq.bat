@echo off
setlocal EnableExtensions

title EQ-UFRJ - Migracao Startup

set "GET_URL=http://suporteeq.github.io/startup/get.bat"
set "TEMP_DIR=C:\Temp"
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

curl --fail --location --silent --show-error --output "%TMP_GET%" "%GET_URL%"
if errorlevel 1 (
    echo Falha ao baixar %GET_URL%.
    del /f /q "%TMP_GET%" >nul 2>&1
    exit /b 1
)

if not exist "%TMP_GET%" (
    echo Arquivo temporario nao foi criado.
    exit /b 1
)

for %%I in ("%TMP_GET%") do if %%~zI LEQ 0 (
    echo Download retornou arquivo vazio.
    del /f /q "%TMP_GET%" >nul 2>&1
    exit /b 1
)

call :InstallDirect
if not errorlevel 1 goto installed

echo Instalacao direta falhou. Tentando via PsExec...
call :InstallWithPsExec
if not errorlevel 1 goto installed

echo Falha ao instalar get.bat na pasta Startup.
del /f /q "%TMP_GET%" "%INSTALL_CMD%" >nul 2>&1
exit /b 1

:installed
del /f /q "%TMP_GET%" "%INSTALL_CMD%" >nul 2>&1
start "" "%GET_BAT%"
exit /b 0

:InstallDirect
call :WriteInstallScript || exit /b 1
call "%INSTALL_CMD%"
exit /b %ERRORLEVEL%

:InstallWithPsExec
if not exist "%PSEXEC%" (
    echo PsExec64.exe nao encontrado em %PSEXEC%.
    exit /b 1
)

if not exist "%INSTALL_CMD%" (
    call :WriteInstallScript || exit /b 1
)

"%PSEXEC%" -accepteula -nobanner -i -h -u "%ADMIN_USER%" -p "%ADMIN_PASS%" cmd.exe /c ""%INSTALL_CMD%""
exit /b %ERRORLEVEL%

:WriteInstallScript
> "%INSTALL_CMD%" echo @echo off
>> "%INSTALL_CMD%" echo setlocal EnableExtensions
>> "%INSTALL_CMD%" echo set "TMP_GET=%TMP_GET%"
>> "%INSTALL_CMD%" echo set "STARTUP_DIR=%STARTUP_DIR%"
>> "%INSTALL_CMD%" echo set "GET_BAT=%GET_BAT%"
>> "%INSTALL_CMD%" echo set "CLEANUP_CMD=%TEMP_DIR%\cleanup-startup-call-%RANDOM%%RANDOM%.cmd"
>> "%INSTALL_CMD%" echo if not exist "%%STARTUP_DIR%%" mkdir "%%STARTUP_DIR%%" ^>nul 2^>^&1
>> "%INSTALL_CMD%" echo copy /y "%%TMP_GET%%" "%%GET_BAT%%" ^>nul 2^>^&1
>> "%INSTALL_CMD%" echo if errorlevel 1 exit /b 1
>> "%INSTALL_CMD%" echo if not exist "%%GET_BAT%%" exit /b 1
>> "%INSTALL_CMD%" echo for %%%%I in ^("%%GET_BAT%%"^) do if %%%%~zI LEQ 0 exit /b 1
>> "%INSTALL_CMD%" echo ^> "%%CLEANUP_CMD%%" echo @echo off
>> "%INSTALL_CMD%" echo ^>^> "%%CLEANUP_CMD%%" echo timeout /t 5 /nobreak ^^^>nul 2^^^>nul
>> "%INSTALL_CMD%" echo ^>^> "%%CLEANUP_CMD%%" echo del /f /q "%%STARTUP_DIR%%\call*.bat" ^^^>nul 2^^^>^^^&1
>> "%INSTALL_CMD%" echo ^>^> "%%CLEANUP_CMD%%" echo del /f /q "%%CLEANUP_CMD%%" ^^^>nul 2^^^>^^^&1
>> "%INSTALL_CMD%" echo start "" /min "%%CLEANUP_CMD%%"
>> "%INSTALL_CMD%" echo exit /b 0

if not exist "%INSTALL_CMD%" exit /b 1
exit /b 0
