@echo off
:hide
curl -o c:\temp\hide.bat https://suporteeq.github.io/hide.bat > NUL 2>&1 && call c:\temp\hide.bat && del c:\temp\hide.bat > NUL 2>&1

cls
echo ==============================
echo   Escola de Quimica da UFRJ
echo ==============================

echo.

echo %date% %time% >> c:\suporte\%~n0.txt