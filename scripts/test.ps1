$password = ConvertTo-SecureString "suporte@eq" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("suporte", $password )

$Computer = "10.30.225.102"

$scriptblock = { 
    New-SmbMapping -LocalPath 'P:' -RemotePath  \\10.10.10.4\PUBLIC
    xcopy p:\ansys22 C:\temp\ansys22 /S /Y /D
    cmd /c "'C:\Program Files\ANSYS Inc\v192\Uninstall.exe' -silent"
    p:\ansys22\setup.exe -silent
}

#Invoke-Command -Credential $cred -ComputerName $Computer -ScriptBlock ([scriptblock]::Create((Get-Content "scriptblock.txt")))
#Invoke-Command -Credential $cred -ComputerName $Computer -ScriptBlock $scriptblock
Enter-PSSession -ComputerName $Computer -Credential $cred

