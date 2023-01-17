$password = ConvertTo-SecureString "PowerEdge 2400" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("administrador", $password )
#OR
#$cred = GetCredential DOMAIN\User
#Enter-PSSession -ComputerName 10.30.225.101 -Credential $cred

#$RemoteComputers = @("10.30.225.101", "10.30.225.102")
$RemoteComputers = Get-Content .\Computers.txt

$scriptblock = { 
    if (Test-Connection -BufferSize 32 -Count 1 -ComputerName 192.168.0.41 -Quiet){
        echo "`t On-line"
        shutdown /r /t 0
        echo "`t Desligando..."
    } else {
        echo "`t Off-line"
    }
}


ForEach ($Computer in $RemoteComputers)
{
    echo ""
    echo $Computer
    Try
        {
            #Invoke-Command -Credential $cred -ComputerName $Computer -ScriptBlock ([scriptblock]::Create((Get-Content "scriptblock.txt")))
            Invoke-Command -Credential $cred -ComputerName $Computer -ScriptBlock $scriptblock
            #Invoke-Command -ComputerName $Computer -ScriptBlock {Get-ChildItem "C:\Program Files"} -ErrorAction Stop
            #Invoke-Command -ComputerName Server01, Server02 -FilePath c:\Scripts\DiskCollect.ps1
            #echo "`t Done"
        }
    Catch
        {
            Add-Content Unavailable-Computers.txt $Computer
            #echo Error
            echo "`t Error"

        }
}


