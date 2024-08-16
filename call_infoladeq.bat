@echo off
cls
curl -o infoladeq.bat https://suporteeq.github.io/infoladeq.bat > NUL 2>&1 && (
    call infoladeq.bat
    del infoladeq.bat > NUL 2>&1
) || (
    call \\10.30.155.1\public\infoladeq.bat || (
            echo "erro" && PAUSE
    )
)