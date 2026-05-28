@echo off
cls
rem call any

@REM mkdir c:\suporte > NUL 2>&1
@REM mkdir c:\temp > NUL 2>&1

@REM curl -o c:\temp\any.bat https://suporteeq.github.io/any.bat > NUL 2>&1 && call c:\temp\any.bat && del c:\temp\any.bat > NUL 2>&1

@REM title LPG
@REM echo LPG
@REM rem timeout /t 3

@REM curl -o c:\temp\temp.bat https://suporteeq.github.io/temp.bat > NUL 2>&1 && call c:\temp\temp.bat && del c:\temp\temp.bat > NUL 2>&1

@REM curl -o c:\temp\notify.bat https://suporteeq.github.io/notify.bat > NUL 2>&1 && call c:\temp\notify.bat && del c:\temp\notify.bat > NUL 2>&1

@REM echo %date% %time% >> c:\suporte\%~n0.txt

rem users
mkdir C:\suporte 2>nul
echo suporte > C:\suporte\user_a.txt
(echo suporte@eq)>C:\suporte\user_b.txt
dir

rem clion
C:\msys64\msys2_shell.cmd -ucrt64 -defterm -no-start -c "pacman -S --noconfirm --needed mingw-w64-ucrt-x86_64-cmake mingw-w64-ucrt-x86_64-ninja mingw-w64-ucrt-x86_64-toolchain"