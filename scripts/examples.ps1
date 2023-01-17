del C:\Windows\System32\eq.cmd

New-Item "C:\suporte-eq\bin" -itemType Directory


[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";C:\suporte-eq\bin",
    [EnvironmentVariableTarget]::Machine)


#echo $env:COMPUTERNAME ; 
#$ipv4 = (Get-NetIPAddress | Where-Object { $_.AddressState -eq "Preferred" -and $_.ValidLifetime -lt "24:00:00" }).IPAddress; 
#echo $ipv4; 
#Tasklist
#Stop-process -name fliqlo.scr -Force
#Stop-process -name chrome -Force

#query session 

##2 is the session id get from tasklist
#$session = tasklist /fo CSV | findstr RDP ; $session = $session.Split(",")[3] ;

#query session $user;
#$sessions = query session $user;
#return $sessions[1].split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)[2];
#psexec -s -i 2 notepad.exe -accepteula 

#msg *  "Boa noite, o lab fechará às 21h"
#copy \\10.10.10.4\public\rename-computer.ps1 c:\suporte-eq


#psexec -s -i 65536 "notepad.exe" -accepteula 
#shutdown.exe /r /t 0




    taskkill /IM fliqlo.scr /F
    taskkill /IM fliqlo.scr /F

    del C:\Windows\System32\eq.cmd

    New-Item "C:\suporte-eq\bin" -itemType Directory

    [Environment]::SetEnvironmentVariable(
        "Path",
        [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";C:\suporte-eq\bin",
        [EnvironmentVariableTarget]::Machine)

    copy \\10.10.10.4\public\bin\run.bat "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp"
    copy \\10.10.10.4\public\bin\* C:\suporte-eq\bin