echo.
@echo off
cls

:title
title ESTA JANELA FECHARA AUTOMATICAMENTE - SUPORTE - EQ/UFRJ

:eqfs01 - link
psexec.exe -accepteula -i -u administrador -p %PASSWORD% c:\suporte\eqfs01\run.bat && cls

:remote
psexec.exe -accepteula -i -u suporte -p %PASSWORD% c:\suporte\remote.bat && cls

:activate
rem psexec.exe -accepteula -i -u administrador -p %PASSWORD% c:\suporte\activate.bat && cls
rem notepad \\10.15.0.3\logs\lpg.txt
rem cmd
rem exit

:admin
rem psexec.exe -accepteula -i -u suporte -p %PASSWORD% c:\suporte\enableadmin.bat && cls

:htri
:htri7
rem psexec.exe -accepteula -i -u administrador -p %PASSWORD% c:\suporte\htri\htri7.bat && cls

:atalhos
psexec.exe -accepteula -i -u administrador -p %PASSWORD% c:\suporte\atalhos.bat && cls

:clocksync
psexec.exe -accepteula -i -u administrador -p %PASSWORD% c:\suporte\clocksync.bat && cls
psexec.exe -accepteula -i -u administrador -p %PASSWORD% c:\suporte\clocksync.bat && cls

:neutron
rem psexec.exe -accepteula -i -u administrador -p %PASSWORD% c:/neutron/settimezone.bat >nul 2>nul 1>NUL && cls
rem psexec.exe -accepteula -i -u administrador -p %PASSWORD% c:/neutron/neutron.exe >nul 2>nul 1>NUL && cls

:unnistall
rem psexec.exe -accepteula -i -u administrador -p %PASSWORD% c:\suporte\unnistall.bat && cls

:delete
rem psexec.exe -accepteula -i -u administrador -p %PASSWORD% c:\suporte\delete_files.bat && cls

:mouse
rem psexec.exe -accepteula -i -u administrador -p %PASSWORD% c:\suporte\mouse.bat && cls

:update_programs
rem psexec.exe -accepteula -i -u administrador -p %PASSWORD% c:\suporte\update.bat && cls

:statistica
rem psexec.exe -accepteula -i -u administrador -p %PASSWORD% c:\suporte\statistica.bat && cls

:PATH
rem regedit /s c:\suporte\path.reg
rem psexec.exe -accepteula -i -u administrador -p %PASSWORD% c:\suporte\path.bat && cls
rem psexec.exe -accepteula -i -u suporte -p %PASSWORD% c:\suporte\path.bat && cls


:autologin
rem psexec.exe -accepteula -i -u administrador -p %PASSWORD% c:\suporte\autologin.bat && cls

:advantage
rem psexec.exe -accepteula -i -u administrador -p %PASSWORD% c:\suporte\advantage.bat && cls

:aspen
rem psexec.exe -accepteula -i -u administrador -p %PASSWORD% c:\suporte\aspen.bat && cls

:ccleaner
rem start c:\suporte\ccleaner.bat

:chemdraw
rem psexec.exe -accepteula -i -u administrador -p %PASSWORD% c:\suporte\chem.bat && cls

:aero
rem psexec.exe -accepteula -i -u administrador -p %PASSWORD% c:\suporte\aero.bat && cls

:ladeqpi
rem psexec.exe -accepteula -i -u administrador -p %PASSWORD% c:\suporte\ladeqpi.bat && cls

:malwarebytes3
rem psexec.exe -accepteula -i -u administrador -p %PASSWORD% c:\suporte\mb3.bat && cls

:devcpp
rem psexec.exe -accepteula -i -u suporte -p %PASSWORD% c:\suporte\devcpp.bat && cls
rem psexec.exe -accepteula -i -u suporte -p %PASSWORD% c:\suporte\htri7.bat && cls

:dx6
rem psexec.exe -accepteula -i -u administrador -p %PASSWORD% c:\suporte\dx6.bat && cls
rem psexec.exe -accepteula -i -u suporte -p %PASSWORD% c:\suporte\dx6.bat && cls

:solver
rem psexec.exe -accepteula -i -u suporte -p %PASSWORD% c:\suporte\solver.bat && cls
rem mkdir "%userprofile%\AppData\Roaming\Microsoft\AddIns"
rem mkdir "%userprofile%\AppData\Roaming\Microsoft\Suplementos"
rem xcopy \\10.15.0.3\suporte\solver\*.* "%userprofile%\AppData\Roaming\Microsoft\AddIns" /Z /Y /S
rem xcopy \\10.15.0.3\suporte\solver\*.* "%userprofile%\AppData\Roaming\Microsoft\Suplementos" /Z /Y /S
rem echo INSTALADO: %computername% ; %USERNAME% ; date: %date% ; %time%   >> "\\10.15.0.3\logs\LABINFO\SOLVER-USER.eq"

:jupyter
rem psexec.exe -accepteula -i -u suporte -p %PASSWORD% c:\suporte\jupyter.bat && cls
rem python -m pip install --upgrade pip
rem python -m pip install jupyter

:visualstudio2013
rem psexec.exe -accepteula -i -u administrador -p %PASSWORD% c:\suporte\vs2013\vns_full.exe && cls

:powerbi
rem psexec.exe -accepteula -i -u administrador -p %PASSWORD% c:\suporte\powerbi.bat && cls

:ansys
rem psexec.exe -accepteula -i -u administrador -p %PASSWORD% c:\suporte\ansys.bat && cls
rem psexec.exe -accepteula -i -u administrador -p %PASSWORD% c:\eqfs01\ansys.bat && cls

:eqfs01 - run
psexec.exe -accepteula -i -u administrador -p %PASSWORD% c:\eqfs01\run.bat && cls

:cmd
rem pause
rem psexec.exe -accepteula -i -u administrador -p %PASSWORD% cmd
rem pause


:exit
echo suporte@eq.ufrj.br|clip  && cls
echo c:\suporte\run.bat|clip  && cls


exit