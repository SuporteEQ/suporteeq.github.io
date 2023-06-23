cls 
$password = ConvertTo-SecureString "PowerEdge 2400" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("administrador", $password )
#OR
#$cred = GetCredential DOMAIN\User
Enter-PSSession -ComputerName 10.30.225.108 -Credential $cred