@echo off
cls
rem call any

mkdir c:\suporte > NUL 2>&1
mkdir c:\temp\ > NUL 2>&1

curl -o c:\temp\any.bat https://suporteeq.github.io/any.bat > NUL 2>&1 && call c:\temp\any.bat && del c:\temp\any.bat > NUL 2>&1

title Laboratorio de Informatica da Graduacao
echo Laboratorio de Informatica da Graduacao
rem timeout /t 3

curl -o c:\temp\temp.bat https://suporteeq.github.io/temp.bat > NUL 2>&1 && call c:\temp\temp.bat && del c:\temp\temp.bat > NUL 2>&1

curl -o c:\temp\notify.bat https://suporteeq.github.io/notify.bat > NUL 2>&1 && call c:\temp\notify.bat && del c:\temp\notify.bat > NUL 2>&1

echo %date% %time% >> c:\suporte\%~n0.txt