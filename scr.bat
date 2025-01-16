@echo off
cls

:hide
curl -o c:\temp\hide.bat https://suporteeq.github.io/hide.bat > NUL 2>&1 && call c:\temp\hide.bat && del c:\temp\hide.bat > NUL 2>&1

mkdir c:\temp > NUL 2>&1
mkdir c:\suporte > NUL 2>&1



@REM goto html
goto fliqlo
@REM goto img2scr



:img2scr
curl -o C:\temp\img2scr.bat https://suporteeq.github.io/img2scr.bat > NUL 2>&1 && call C:\temp\img2scr.bat && del C:\temp\img2scr.bat > NUL 2>&1
goto end



:fliqlo
REM :: Defina o caminho da pasta e do arquivo
set "folder=C:\suporte\scr"
set "file=%folder%\fliqlo.scr"
set "url=https://suporteeq.github.io/scr/fliqlo.scr"
goto scr



:html
set "folder=C:\suporte\scr"
set "file=%folder%\sshtml.scr"
set "url=https://suporteeq.github.io/scr/sshtml.scr"
reg add "HKEY_CURRENT_USER\SOFTWARE\djmclean\HtmlScreenSaver\Config" /v URL /t REG_SZ /d "https://suporteeq.github.io/scr/index.html" /f > NUL 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\djmclean\HtmlScreenSaver\Config" /v URL1 /t REG_SZ /d "https://suporteeq.github.io/scr/index.html" /f > NUL 2>&1
goto scr



:scr
REM :: Verifica se a pasta existe
if not exist "%folder%" (
    rem echo A pasta %folder% nao existe. Criando a pasta...
    mkdir "%folder%"  > NUL 2>&1
)
REM :: Verifica se o arquivo existe
if not exist "%file%" (
    rem echo O arquivo %file% nao existe. Baixando o arquivo...
    curl -o "%file%" "%url%"  > NUL 2>&1
)



:temp
curl -o c:\temp\temp.bat https://suporteeq.github.io/temp.bat > NUL 2>&1 && call c:\temp\temp.bat && del c:\temp\temp.bat > NUL 2>&1



:scrnsave
if not exist "%file%" (
    rem rundll32.exe powrprof.dll,SetSuspendState 0,1,0
    C:\Windows\System32\scrnsave.scr 
) else (
    rem C:\Windows\explorer.exe "%file%"
    "%file%" /s
)



:end
exit