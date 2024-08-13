@echo off
cls
echo iniciando PROTETOR DE TELA
TIMEOUT /t 1800
rundll32.exe powrprof.dll,SetSuspendState 0,1,0
timeout /t 10800 /nobreak > NUL
shutdown /h
