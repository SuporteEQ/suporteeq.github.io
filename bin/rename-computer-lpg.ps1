$nname = Read-Host "Qual sera o nome do computador?"
$rename = "LPG-$nname"
cls
echo O Computador sera chamado de ... apos a reinicializacao:
echo $rename
pause
Rename-Computer -NewName $rename -Restart