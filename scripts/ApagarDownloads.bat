@echo off

powershell Remove-Item c:\users\%username%\downloads\* -Recurse -Force
powershell Remove-Item C:\Users\EQ\Desktop\* -Recurse -Force
powershell Remove-Item C:\Users\EQ\Documents\* -Recurse -Force
powershell Remove-Item C:\Users\EQ\Pictures\* -Recurse -Force
powershell Remove-Item C:\Users\EQ\Music\* -Recurse -Force
powershell Remove-Item C:\Users\EQ\Videos\* -Recurse -Force


ECHO -------------------------------
ECHO -         ALERTA              -
ECHO -------------------------------
echo TODOS OS ARQUIVOS SAO APAGADOS 
echo QUANDO O COMPUTADOR REINICIA
ECHO -------------------------------

