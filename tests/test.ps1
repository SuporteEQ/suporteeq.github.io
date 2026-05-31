Write-Host "Ola, eu sou um admin?"
(New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Read-Host -Prompt "Pressione Enter para continuar"