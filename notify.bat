@echo off
cls
cls
title siga @equfrj no instagram 

curl -o c:\temp\telegram.bat https://suporteeq.github.io/telegram.bat > NUL 2>&1 && call c:\temp\telegram.bat && del c:\temp\telegram.bat > NUL 2>&1


msg * Todos os arquivos sao apagados da area de trabalho e da pasta download quando o computador reinicia.
msg * Siga @equfrj no instagram
@REM msg * Todos os arquivos sao apagados da area de trabalho e da pasta download quando o computador reinicia.
@REM msg * Siga @equfrj no instagram
@REM echo --------------------------
@REM echo siga @equfrj no instagram
@REM echo --------------------------
@REM timeout /t 60

echo %date% %time% >> c:\suporte\%~n0.txt