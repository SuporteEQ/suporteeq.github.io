@echo off
setlocal

@REM curl -o c:\temp\meshagent64.exe https://suporteeq.github.io/meshagent64.exe > NUL 2>&1 
@REM psexec -u Administrador -p SENHA@SENHA "C:\Temp\meshagent64.exe" -fullinstall
@REM del c:\temp\meshagent64.exe > NUL 2>&1



set "SERVICE_NAME=Mesh Agent"
set "INSTALLER=C:\Temp\MeshAgent64.exe"
set "DOWNLOAD_URL=https://suporteeq.github.io/meshcentral/meshagent64.exe"

:: Se o serviço já existe, encerra
sc query "%SERVICE_NAME%" >nul 2>&1
if %errorlevel%==0 (
    exit /b 0
)

:: Cria a pasta C:\Temp caso não exista
if not exist "C:\Temp" (
    mkdir "C:\Temp"
)

:: Se o instalador não existir, faz o download
if not exist "%INSTALLER%" (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%INSTALLER%'"
)

:: Verifica se o download foi realizado
if not exist "%INSTALLER%" (
    exit /b 1
)

:: Instala o MeshAgent
"%INSTALLER%" -fullinstall

exit /b 0