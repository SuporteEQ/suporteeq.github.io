cls 
$password = ConvertTo-SecureString "PowerEdge 2400" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("administrador", $password )
$RemoteComputers = Get-Content .\Computers.txt


$scriptblock = { 
    param($Computer)
    try {
        if(Test-Connection -BufferSize 32 -Count 1 -ComputerName $Computer -Quiet){
            echo "`t On-line"
        } else {
            echo "`t Off-line"
        }

        #kill-sacreensaver
        #taskkill /IM fliqlo.scr /F
        
        #miniminiza tudo
        #$shell = New-Object -ComObject "Shell.Application"
        #$shell.minimizeall()

        #mensagem-balao
        <#
        [reflection.assembly]::loadwithpartialname('System.Windows.Forms')
        [reflection.assembly]::loadwithpartialname('System.Drawing')
        $notify = new-object system.windows.forms.notifyicon
        $notify.icon = [System.Drawing.SystemIcons]::Information
        $notify.visible = $true
        $notify.showballoontip(10, 'EQ', 'Boa tarde!', [system.windows.forms.tooltipicon]::None)
        #>
        
        #mensagem-popup
        <#
        [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
        [System.Windows.Forms.MessageBox]::Show('Boa tarde!','EQ')
        #>
        
        #mensagem-padrao
        <#
        #>
        msg * "Boa noite! O laboratório fechará às 21h."
        
        #enviar tecla
        #https://www.jesusninoc.com/11/05/simulate-key-press-by-user-with-sendkeys-and-powershell/
        #[System.Windows.Forms.SendKeys]::SendWait("{ESC}")
        #[System.Windows.Forms.SendKeys]::SendWait("%{F4}")
        
        
        #move mouse
        <#
        $Pos = [System.Windows.Forms.Cursor]::Position
        [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point((($Pos.X) + 1) , $Pos.Y)
        #>
        
        #procura usuarios
        #quser /server:$Computer
        
        #log no usuario 1
        #Logoff 1 /server:$Computer
        
        #desliga
        <#
        shutdown /s /t 0
        echo "`t Desligando..."
        #>
        
        #reinicia
        <#
        shutdown /r /t 0
        echo "`t Reiniciando..."
        #>
        
        #cmd
        #cmd /c "echo %computername%"
        
        #TESTE
        #taskkill /IM WINWORD.exe /F
        #taskkill /IM chrome.exe /F
        #taskkill /IM notepad.exe /F
        #Invoke-Expression -Command "c:\Windows\notepad.exe"

    }
    catch {
        echo "`t Off-line"
    }

}


echo ""
ForEach ($Computer in $RemoteComputers) {
    
    if ($Computer.StartsWith("#")) {
        #echo "`t skipping"
    } else {
        echo $($Computer)
        Try {
            Invoke-Command -Credential $cred -ComputerName $Computer -ScriptBlock $scriptblock -ArgumentList $Computer
        }
        Catch {
            echo "`t Error"
        }
    }
}


