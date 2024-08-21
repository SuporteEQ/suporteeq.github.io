@echo off
cls
setlocal enabledelayedexpansion


@echo off

SET "jpegview=C:\suporte\jpegview\jpegview.exe"

IF NOT EXIST "%jpegview%" (
    mkdir c:\suporte 
    curl -o "C:\suporte\jpegview.zip" https://suporteeq.github.io/util/jpegview.zip --create-dirs --fail --silent --show-error
    tar -xf "C:\suporte\jpegview.zip" -C c:\suporte
    del "C:\suporte\jpegview.zip"
)

IF NOT EXIST "%jpegview%" (
    exit
)

:: Lista de URLs das imagens
@REM set "urls[0]=https://placehold.co/800x600/png"
set "urls[0]=https://eq.ufrj.br/wp-content/uploads/2024/08/logo_seq2024.jpeg"
set "urls[1]=https://eq.ufrj.br/wp-content/uploads/2024/08/nuvem_seq2024.png"


:: Calcula o número total de URLs
set /a "count=2"

:: Gera um número aleatório entre 0 e count-1
set /a "index=!random! %% count"

:: Seleciona a URL aleatória
set "imageURL=!urls[%index%]!"
@REM set "imageURL=!urls[8]!"

:: Extrai a extensão da URL
for %%A in ("%imageURL%") do set "extension=%%~xA"

:: Define a extensão padrão se a extensão não for encontrada
if "%extension%"=="" set "extension=.png"

:: Define o nome da imagem a ser salva localmente com a extensão extraída
set "imageName=new_image%extension%"

:: Define o diretório temporário
set "tempDir=%temp%"

:: Define o caminho completo da imagem no diretório temporário
set "imagePath=%tempDir%\%imageName%"

:: Remove a imagem se já existir
del "%imagePath%" 2>nul

:: Baixa a imagem
curl -o "%imagePath%" %imageURL% --create-dirs --fail --silent --show-error

:: Fecha todas as instâncias do JPEGView
taskkill /IM JPEGView.exe /F /T >nul 2>&1

:: Exibe a imagem em tela cheia usando o Visualizador de Imagens
"%jpegview%" -fullscreen "%imagePath%"

:: Aguarda um curto período para garantir que o JPEGView esteja aberto
timeout /t 1 >nul

:: Fecha todas as instâncias do JPEGView
taskkill /IM JPEGView.exe /F /T >nul 2>&1

:: Remove a imagem após o fechamento do JPEGView
del "%imagePath%"
