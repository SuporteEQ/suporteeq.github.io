rem @echo off && cls && curl -o lpg.bat https://suporteeq.github.io/lpg.bat > NUL 2>&1 && call lpg.bat && del lpg.bat > NUL 2>&1

@echo off
cls
curl -o lpg.bat https://suporteeq.github.io/lpg.bat > NUL 2>&1 && (
    call lpg.bat
    del lpg.bat > NUL 2>&1
) || (
    echo "erro na rede"
)