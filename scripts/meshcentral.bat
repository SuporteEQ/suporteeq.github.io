@echo off

curl -o c:\temp\meshagent64.exe https://suporteeq.github.io/meshagent64.exe > NUL 2>&1 

psexec -u Administrador -p SENHA@SENHA "C:\Temp\meshagent64.exe" -fullinstall

del c:\temp\meshagent64.exe > NUL 2>&1