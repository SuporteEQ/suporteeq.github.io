$password = ConvertTo-SecureString "PowerEdge 2400" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("administrador", $password )
#OR
#$cred = GetCredential DOMAIN\User
#Enter-PSSession -ComputerName 10.30.225.101 -Credential $cred

#$RemoteComputers = @("10.30.225.101", "10.30.225.102")
$RemoteComputers = Get-Content .\Computers.txt
""  >   .\Computers-done.txt
""  >   .\Computers-done-else.txt
""  >   .\Computers-trying.txt
""  >   .\Computers-Unavailable.txt


$scriptblock = { 
    param($Computer)
    #https://stackoverflow.com/questions/16347214/pass-arguments-to-a-scriptblock-in-powershell
    echo ""
    echo $($Computer)
    if (Test-Connection -BufferSize 32 -Count 1 -ComputerName $Computer -Quiet) {
        echo "`t On-line"
        shutdown /s /t 0
        echo "`t Desligando..."
        $Computer  >>  .\Computers-done.txt
    }
    else {
        echo "`t Off-line"
        $Computer  >>  .\Computers-done-else.txt
    }
    
    echo ""
}


ForEach ($Computer in $RemoteComputers) {
    $Computer >> .\Computers-trying.txt

    Try {
        #Invoke-Command -Credential $cred -ComputerName $Computer -ScriptBlock ([scriptblock]::Create((Get-Content "scriptblock.txt")))
        Invoke-Command -Credential $cred -ComputerName $Computer -ScriptBlock $scriptblock -ArgumentList $Computer
        #Invoke-Command -ComputerName $Computer -ScriptBlock {Get-ChildItem "C:\Program Files"} -ErrorAction Stop
        #Invoke-Command -ComputerName Server01, Server02 -FilePath c:\Scripts\DiskCollect.ps1
        #echo "`t Done"
    }
    Catch {
        $Computer  >>  .\Computers-Unavailable.txt
        #echo Error
        echo "`t Error"

    }

 
}


