@echo off
cls
mkdir c:\suporte > NUL 2>&1
mkdir c:\temp > NUL 2>&1

@REM curl -o C:\temp\scr.bat https://suporteeq.github.io/scr.bat > NUL 2>&1 && call C:\temp\scr.bat && del C:\temp\scr.bat > NUL 2>&1
curl -o C:\temp\img2scr.bat https://suporteeq.github.io/img2scr.bat > NUL 2>&1 && call C:\temp\img2scr.bat && del C:\temp\img2scr.bat > NUL 2>&1

