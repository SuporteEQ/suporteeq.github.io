@echo off
cls
setlocal

set "tempDir=C:\Temp"
set "baseUrl=https://suporteeq.github.io/startup"
set "workDir=%tempDir%\startup-%RANDOM%"

if not exist "%tempDir%" (
    mkdir "%tempDir%"
)

if exist "%workDir%" (
    rmdir /s /q "%workDir%" > NUL 2>&1
)

mkdir "%workDir%" > NUL 2>&1 || (
    echo Nao foi possivel criar a pasta temporaria.
    pause
    exit /b 1
)

cd /d "%workDir%" || (
    echo Nao foi possivel acessar a pasta temporaria.
    pause
    exit /b 1
)

call :DownloadFile "run.bat" "%baseUrl%/run.bat" || goto download_failed
call :DownloadFile "auto.bat" "%baseUrl%/auto.bat" || goto download_failed
call :DownloadFile "manual.bat" "%baseUrl%/manual.bat" || goto download_failed
call :DownloadFile "manual-botoes.txt" "%baseUrl%/manual-botoes.txt" || goto download_failed

call run.bat
set "exitCode=%ERRORLEVEL%"

cd /d "%tempDir%" > NUL 2>&1
rmdir /s /q "%workDir%" > NUL 2>&1

exit /b %exitCode%

:download_failed
cd /d "%tempDir%" > NUL 2>&1
rmdir /s /q "%workDir%" > NUL 2>&1
pause
exit /b 1

:DownloadFile
echo Baixando %~1...
curl --fail --location --show-error --output "%~1" "%~2"
if errorlevel 1 (
    echo Falha ao baixar: %~2
    exit /b 1
)

if not exist "%~1" (
    echo Arquivo nao encontrado apos download: %~1
    exit /b 1
)

exit /b 0
