@echo off
cls
echo EQ-UFRJ
PAUSE
psexec.exe -accepteula -i -u suporte -p suporte@eq c:\suporte-eq\bin\rename-lpg.bat && cls
