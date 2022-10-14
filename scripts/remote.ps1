$password = ConvertTo-SecureString "PowerEdge 2400" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("administrador", $password )
#OR
#$cred = GetCredential DOMAIN\User
#Enter-PSSession -ComputerName 10.30.225.101 -Credential $cred

#$RemoteComputers = @("10.30.225.101", "10.30.225.102")
$RemoteComputers = Get-Content .\Computers.txt

$scriptblock = { 
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
}


ForEach ($Computer in $RemoteComputers)
{
    echo $Computer
    Try
        {
            #Invoke-Command -Credential $cred -ComputerName $Computer -ScriptBlock ([scriptblock]::Create((Get-Content "scriptblock.txt")))
            Invoke-Command -Credential $cred -ComputerName $Computer -ScriptBlock $scriptblock
            #Invoke-Command -ComputerName $Computer -ScriptBlock {Get-ChildItem "C:\Program Files"} -ErrorAction Stop
            #Invoke-Command -ComputerName Server01, Server02 -FilePath c:\Scripts\DiskCollect.ps1
            echo Done
        }
    Catch
        {
            echo Error
            Add-Content Unavailable-Computers.txt $Computer
        }
}


