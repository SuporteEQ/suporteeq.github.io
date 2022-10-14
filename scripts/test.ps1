$password = ConvertTo-SecureString "suporte@eq" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("suporte", $password )

$Computer = "10.30.225.102"

$scriptblock = { 
    Start-Process -FilePath '\\10.30.225.12\temp\test.bat' -NoNewWindow
}

#Invoke-Command -Credential $cred -ComputerName $Computer -ScriptBlock ([scriptblock]::Create((Get-Content "scriptblock.txt")))
#Invoke-Command -Credential $cred -ComputerName $Computer -ScriptBlock $scriptblock
Enter-PSSession -ComputerName $Computer -Credential $cred

