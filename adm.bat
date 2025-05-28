@echo off
cls
rem call any
curl -o any.bat https://suporteeq.github.io/any.bat > NUL 2>&1 && call any.bat && del any.bat > NUL 2>&1

echo Admnistracao
timeout /t 10

echo %date% %time% >> c:\suporte\%~n0.txt