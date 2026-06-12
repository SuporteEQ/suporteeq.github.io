@echo off
setlocal
set "SCRIPT_FILE=%~f0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$path = $env:SCRIPT_FILE; $raw = [IO.File]::ReadAllText($path); $marker = '# POWERSHELL_START'; $idx = $raw.LastIndexOf($marker); if ($idx -lt 0) { throw 'Bloco PowerShell nao encontrado.' }; $code = $raw.Substring($idx + $marker.Length); Invoke-Expression $code"
exit /b %ERRORLEVEL%

# POWERSHELL_START

$ScriptRoot = Split-Path -Parent $env:SCRIPT_FILE
$ButtonsConfig = Join-Path $ScriptRoot 'manual-botoes.txt'
$AutoScript = Join-Path $ScriptRoot 'auto.bat'
$WorkDir = 'C:\temp'
$LogDir = Join-Path $WorkDir 'logs'
$CmdDir = Join-Path $WorkDir 'cmd'
$AdminUserFile = 'C:\temp\user_a.txt'
$AdminPasswordFile = 'C:\temp\user_b.txt'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$RunningProcesses = New-Object System.Collections.Generic.List[object]

function Expand-ConfigValue {
    param([string]$Value)

    $expanded = $Value.Replace('%SCRIPT_DIR%', $ScriptRoot)
    $expanded = $expanded.Replace('%AUTO_BAT%', $AutoScript)
    [Environment]::ExpandEnvironmentVariables($expanded)
}

function Show-Warning {
    param([string]$Title, [string]$Message)

    [System.Windows.Forms.MessageBox]::Show(
        $Message,
        $Title,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    ) | Out-Null
}

function Show-Info {
    param([string]$Title, [string]$Message)

    [System.Windows.Forms.MessageBox]::Show(
        $Message,
        $Title,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
}

function Hide-ConsoleWindow {
    try {
        if (-not ('ManualMode.ConsoleWindow' -as [type])) {
            Add-Type -Namespace ManualMode -Name ConsoleWindow -MemberDefinition @'
[System.Runtime.InteropServices.DllImport("kernel32.dll")]
public static extern System.IntPtr GetConsoleWindow();

[System.Runtime.InteropServices.DllImport("user32.dll")]
public static extern bool ShowWindow(System.IntPtr hWnd, int nCmdShow);
'@
        }

        $consoleWindow = [ManualMode.ConsoleWindow]::GetConsoleWindow()

        if ($consoleWindow -ne [IntPtr]::Zero) {
            [ManualMode.ConsoleWindow]::ShowWindow($consoleWindow, 0) | Out-Null
        }
    } catch {
    }
}

function Show-ConsoleWindow {
    try {
        $consoleWindow = [ManualMode.ConsoleWindow]::GetConsoleWindow()

        if ($consoleWindow -ne [IntPtr]::Zero) {
            [ManualMode.ConsoleWindow]::ShowWindow($consoleWindow, 5) | Out-Null
        }
    } catch {
    }
}

function Ensure-WorkDirs {
    foreach ($directory in @($WorkDir, $LogDir, $CmdDir)) {
        if (-not (Test-Path -LiteralPath $directory)) {
            New-Item -ItemType Directory -Path $directory -Force -ErrorAction Stop | Out-Null
        }
    }
}

function New-ButtonConfig {
    [PSCustomObject]@{
        Title = ''
        Commands = New-Object System.Collections.Generic.List[string]
        VerifyPaths = New-Object System.Collections.Generic.List[string]
        Admin = $false
        Elevate = $false
        Message = ''
    }
}

function Add-ButtonConfig {
    param([System.Collections.Generic.List[object]]$Buttons, [object]$Button)

    if ($null -eq $Button) {
        return
    }

    if ([string]::IsNullOrWhiteSpace($Button.Title) -or $Button.Commands.Count -eq 0) {
        return
    }

    $Buttons.Add($Button)
}

function Read-ButtonConfigs {
    if (-not (Test-Path -LiteralPath $ButtonsConfig)) {
        Show-Warning -Title 'Configuracao ausente' -Message "Arquivo nao encontrado:`r`n$ButtonsConfig"
        return @()
    }

    $buttons = New-Object System.Collections.Generic.List[object]
    $current = $null
    $commandBlockButton = $null
    $commandBlockStartLine = 0
    $commandBlockStartCount = 0
    $lineNumber = 0

    foreach ($line in Get-Content -LiteralPath $ButtonsConfig -Encoding Default) {
        $lineNumber++
        $trimmed = $line.Trim()

        if ($null -ne $commandBlockButton) {
            if ($trimmed -eq '}') {
                $commandBlockButton = $null
                $commandBlockStartLine = 0
                $commandBlockStartCount = 0
                continue
            }

            if ([string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith('#')) {
                continue
            }

            $commandBlockButton.Commands.Add($trimmed)
            continue
        }

        if ([string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith('#')) {
            continue
        }

        if ($trimmed -match '^\[(.+)\]$') {
            Add-ButtonConfig -Buttons $buttons -Button $current
            $section = $matches[1].Trim().ToLowerInvariant()

            if ($section -eq 'botao') {
                $current = New-ButtonConfig
            } else {
                $current = $null
            }

            continue
        }

        if ($null -eq $current) {
            continue
        }

        if ($trimmed -notmatch '^([^=]+)=(.*)$') {
            Show-Warning -Title 'Linha ignorada' -Message "Linha $lineNumber invalida em manual-botoes.txt:`r`n$line"
            continue
        }

        $key = $matches[1].Trim().ToLowerInvariant()
        $value = $matches[2].Trim()

        if ($key -eq 'comando' -or $key -eq 'command') {
            if ($value -eq '{') {
                $commandBlockButton = $current
                $commandBlockStartLine = $lineNumber
                $commandBlockStartCount = $current.Commands.Count
            } else {
                $current.Commands.Add($value)
            }

            continue
        }

        switch ($key) {
            'titulo' { $current.Title = $value }
            'title' { $current.Title = $value }
            'verificar' { $current.VerifyPaths.Add($value) }
            'check' { $current.VerifyPaths.Add($value) }
            'admin' {
                if ($value -match '^(sim|s|true|1|yes|y)$') {
                    $current.Admin = $true
                } elseif ($value -match '^(nao|n|false|0|no)$') {
                    $current.Admin = $false
                } else {
                    Show-Warning -Title 'Valor de admin ignorado' -Message "Linha $lineNumber tem admin invalido:`r`n$value`r`n`r`nUse true ou false."
                }
            }
            'elevate' {
                if ($value -match '^(sim|s|true|1|yes|y)$') {
                    $current.Elevate = $true
                } elseif ($value -match '^(nao|n|false|0|no)$') {
                    $current.Elevate = $false
                } else {
                    Show-Warning -Title 'Valor de elevate ignorado' -Message "Linha $lineNumber tem elevate invalido:`r`n$value`r`n`r`nUse true ou false."
                }
            }
            'mensagem' { $current.Message = $value }
            'message' { $current.Message = $value }
        }
    }

    if ($null -ne $commandBlockButton) {
        while ($commandBlockButton.Commands.Count -gt $commandBlockStartCount) {
            $commandBlockButton.Commands.RemoveAt($commandBlockButton.Commands.Count - 1)
        }

        Show-Warning -Title 'Bloco de comandos ignorado' -Message "Bloco iniciado na linha $commandBlockStartLine nao foi fechado com } em manual-botoes.txt."
    }

    Add-ButtonConfig -Buttons $buttons -Button $current
    return $buttons.ToArray()
}

function Split-CommandLine {
    param([string]$Command)

    $trimmed = $Command.Trim()

    if ($trimmed -match '^"([^"]+)"\s*(.*)$') {
        return [PSCustomObject]@{ Target = $matches[1]; Arguments = $matches[2].Trim() }
    }

    if ($trimmed -match '^(\S+)\s*(.*)$') {
        return [PSCustomObject]@{ Target = $matches[1]; Arguments = $matches[2].Trim() }
    }

    [PSCustomObject]@{ Target = ''; Arguments = '' }
}

function Convert-CommandForBatch {
    param([string]$Command)

    $expandedCommand = Expand-ConfigValue -Value $Command
    $parts = Split-CommandLine -Command $expandedCommand
    $extension = [IO.Path]::GetExtension($parts.Target).ToLowerInvariant()

    if ($extension -eq '.ps1') {
        $line = ('powershell.exe -NoProfile -ExecutionPolicy Bypass -File "{0}"' -f $parts.Target)

        if (-not [string]::IsNullOrWhiteSpace($parts.Arguments)) {
            $line = "$line $($parts.Arguments)"
        }

        return $line
    }

    if ($extension -eq '.bat' -or $extension -eq '.cmd') {
        $line = ('call "{0}"' -f $parts.Target)

        if (-not [string]::IsNullOrWhiteSpace($parts.Arguments)) {
            $line = "$line $($parts.Arguments)"
        }

        return $line
    }

    return $expandedCommand
}

function Test-CredentialFiles {
    if (-not (Test-Path -LiteralPath $AdminUserFile)) {
        throw "Arquivo de usuario administrador nao encontrado: $AdminUserFile"
    }

    if (-not (Test-Path -LiteralPath $AdminPasswordFile)) {
        throw "Arquivo de senha administrador nao encontrado: $AdminPasswordFile"
    }
}

function Normalize-AdminUserName {
    param([string]$UserName)

    $trimmed = $UserName.Trim()

    if ($trimmed -match '^[^\\]+\\[^\\]+$' -or $trimmed -match '^\.\\[^\\]+$' -or $trimmed -match '^[^@]+@[^@]+$') {
        return $trimmed
    }

    return ("{0}\{1}" -f $env:COMPUTERNAME, $trimmed)
}

function Get-AdminCredentialConfig {
    Test-CredentialFiles

    try {
        $userName = ([IO.File]::ReadAllText($AdminUserFile)).Trim()
        $password = ([IO.File]::ReadAllText($AdminPasswordFile)).TrimEnd([char[]]"`r`n")
    } catch {
        throw "Nao foi possivel ler os arquivos de credenciais administrativas. $($_.Exception.Message)"
    }

    if ([string]::IsNullOrWhiteSpace($userName)) {
        throw "Arquivo de usuario administrador esta vazio: $AdminUserFile"
    }

    if ([string]::IsNullOrEmpty($password)) {
        throw "Arquivo de senha administrador esta vazio: $AdminPasswordFile"
    }

    [PSCustomObject]@{ UserName = (Normalize-AdminUserName -UserName $userName); Password = $password }
}

function ConvertTo-CommandLineArgument {
    param([string]$Argument)

    if ($null -eq $Argument) {
        return '""'
    }

    if ($Argument -notmatch '[\s"]') {
        return $Argument
    }

    $builder = New-Object System.Text.StringBuilder
    [void]$builder.Append('"')
    $backslashes = 0

    foreach ($character in $Argument.ToCharArray()) {
        if ($character -eq '\') {
            $backslashes++
            continue
        }

        if ($character -eq '"') {
            [void]$builder.Append(('\' * (($backslashes * 2) + 1)))
            [void]$builder.Append('"')
            $backslashes = 0
            continue
        }

        if ($backslashes -gt 0) {
            [void]$builder.Append(('\' * $backslashes))
            $backslashes = 0
        }

        [void]$builder.Append($character)
    }

    if ($backslashes -gt 0) {
        [void]$builder.Append(('\' * ($backslashes * 2)))
    }

    [void]$builder.Append('"')
    return $builder.ToString()
}

function ConvertTo-CommandLine {
    param([string[]]$Arguments)

    ($Arguments | ForEach-Object { ConvertTo-CommandLineArgument -Argument $_ }) -join ' '
}

function Invoke-NativeCommand {
    param([string]$FilePath, [string[]]$Arguments, [int]$TimeoutSeconds = 0)

    Ensure-WorkDirs

    $id = [guid]::NewGuid().ToString('N')
    $stdoutPath = Join-Path $LogDir ("native-{0}.out" -f $id)
    $stderrPath = Join-Path $LogDir ("native-{0}.err" -f $id)

    try {
        Remove-Item -LiteralPath $stdoutPath, $stderrPath -Force -ErrorAction SilentlyContinue
        $argumentLine = ConvertTo-CommandLine -Arguments $Arguments
        $process = Start-Process -FilePath $FilePath -ArgumentList $argumentLine -PassThru -NoNewWindow -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath -ErrorAction Stop

        if ($TimeoutSeconds -gt 0) {
            if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
                try {
                    $process.Kill()
                } catch {
                }

                return [PSCustomObject]@{
                    ExitCode = 1
                    Output = "Tempo limite aguardando $FilePath."
                }
            }
        } else {
            $process.WaitForExit()
        }

        $output = New-Object System.Collections.Generic.List[string]

        foreach ($path in @($stdoutPath, $stderrPath)) {
            if (Test-Path -LiteralPath $path) {
                $text = [IO.File]::ReadAllText($path)

                if (-not [string]::IsNullOrWhiteSpace($text)) {
                    $output.Add($text.TrimEnd())
                }
            }
        }

        [PSCustomObject]@{
            ExitCode = $process.ExitCode
            Output = ($output.ToArray() -join "`r`n")
        }
    } catch {
        [PSCustomObject]@{
            ExitCode = 1
            Output = $_.Exception.Message
        }
    } finally {
        Remove-Item -LiteralPath $stdoutPath, $stderrPath -Force -ErrorAction SilentlyContinue
    }
}

function Write-FailureLog {
    param([string]$Prefix, [int]$ExitCode, [string]$Output)

    Ensure-WorkDirs
    $logPath = Join-Path $LogDir ("{0}-{1}.log" -f $Prefix, ([guid]::NewGuid().ToString('N')))
    $lines = @(
        ("Data: {0}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')),
        ("Codigo: {0}" -f $ExitCode),
        '',
        $Output
    )

    Set-Content -LiteralPath $logPath -Value $lines -Encoding Default -ErrorAction Stop
    return $logPath
}

function Resolve-PsExecPath {
    Ensure-WorkDirs
    Write-Host 'Aguarde...'

    $candidates = @(
        (Join-Path $ScriptRoot 'PsExec64.exe'),
        (Join-Path $ScriptRoot 'PsExec.exe'),
        'C:\temp\pstools\PsExec64.exe',
        'C:\temp\pstools\PsExec.exe'
    )

    foreach ($candidate in $candidates) {
        if ((Test-Path -LiteralPath $candidate) -and ((Get-Item -LiteralPath $candidate).Length -gt 0)) {
            return $candidate
        }
    }

    foreach ($name in @('PsExec64.exe', 'PsExec.exe')) {
        $command = Get-Command $name -ErrorAction SilentlyContinue

        if ($null -ne $command -and (Test-Path -LiteralPath $command.Source)) {
            return $command.Source
        }
    }

    $toolsDir = 'C:\temp\pstools'

    if (-not (Test-Path -LiteralPath $toolsDir)) {
        New-Item -ItemType Directory -Path $toolsDir -Force -ErrorAction Stop | Out-Null
    }

    foreach ($name in @('PsExec64.exe', 'PsExec.exe')) {
        $target = Join-Path $toolsDir $name
        $url = "https://suporteeq.github.io/util/pstools/$name"

        try {
            Invoke-WebRequest -Uri $url -OutFile $target -UseBasicParsing -ErrorAction Stop | Out-Null

            if ((Test-Path -LiteralPath $target) -and ((Get-Item -LiteralPath $target).Length -gt 0)) {
                return $target
            }
        } catch {
            Remove-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue
        }
    }

    throw 'Nao foi possivel preparar a ferramenta de execucao administrativa.'
}

function Remove-TemporaryCmdFile {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return
    }

    try {
        $resolved = Resolve-Path -LiteralPath $Path -ErrorAction SilentlyContinue

        if ($null -eq $resolved) {
            return
        }

        foreach ($item in $resolved) {
            if ($item.Path.StartsWith($CmdDir, [StringComparison]::OrdinalIgnoreCase) -and $item.Path.EndsWith('.cmd', [StringComparison]::OrdinalIgnoreCase)) {
                Remove-Item -LiteralPath $item.Path -Force -ErrorAction SilentlyContinue
            }
        }
    } catch {
    }
}

function New-CommandScript {
    param([System.Collections.Generic.List[string]]$Commands, [string]$Prefix)

    Ensure-WorkDirs
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add('@echo off')
    $lines.Add('setlocal')

    foreach ($command in $Commands) {
        $line = Convert-CommandForBatch -Command $command

        if ($false -eq $line) {
            return $false
        }

        $lines.Add($line)
    }

    $lines.Add('set "EXIT_CODE=%ERRORLEVEL%"')
    $lines.Add('if "%EXIT_CODE%"=="0" (del /f /q "%~f0" >nul 2>&1 & exit /b 0)')
    $lines.Add('exit /b %EXIT_CODE%')

    $path = Join-Path $CmdDir ("{0}-{1}.cmd" -f $Prefix, ([guid]::NewGuid().ToString('N')))
    Set-Content -LiteralPath $path -Value $lines.ToArray() -Encoding Default -ErrorAction Stop
    return $path
}

function Invoke-PsExecLocalCommand {
    param([string]$CommandScript)

    $credential = Get-AdminCredentialConfig
    $psexecPath = Resolve-PsExecPath

    $arguments = New-Object System.Collections.Generic.List[string]
    $arguments.Add('-accepteula')
    $arguments.Add('-nobanner')
    $arguments.Add('-i')
    $arguments.Add('-u')
    $arguments.Add($credential.UserName)
    $arguments.Add('-p')
    $arguments.Add($credential.Password)
    $arguments.Add('cmd.exe')
    $arguments.Add('/c')
    $arguments.Add($CommandScript)

    Invoke-NativeCommand -FilePath $psexecPath -Arguments $arguments.ToArray()
}

function Start-AdminPsExecCommand {
    param([string]$CommandScript)

    try {
        $result = Invoke-PsExecLocalCommand -CommandScript $CommandScript
    } catch {
        $logPath = Write-FailureLog -Prefix 'manual-admin' -ExitCode 1 -Output $_.Exception.Message
        Show-Warning -Title 'Erro na execucao administrativa' -Message "Nao foi possivel iniciar a execucao via PsExec.`r`n`r`nLog:`r`n$logPath"
        return $false
    }

    if ($result.ExitCode -eq 0) {
        Remove-TemporaryCmdFile -Path $CommandScript
        return $true
    }

    $logPath = Write-FailureLog -Prefix 'manual-admin' -ExitCode $result.ExitCode -Output $result.Output
    Show-Warning -Title 'Erro na execucao administrativa' -Message "A execucao via PsExec terminou com codigo $($result.ExitCode).`r`n`r`nLog:`r`n$logPath"
    return $false
}

function Start-ElevatedUacCommand {
    param([string]$CommandScript)

    try {
        $process = Start-Process -FilePath 'cmd.exe' -ArgumentList @('/c', ('"{0}"' -f $CommandScript)) -Verb RunAs -Wait -PassThru -ErrorAction Stop
    } catch {
        $logPath = Write-FailureLog -Prefix 'manual-elevate' -ExitCode 1 -Output $_.Exception.Message
        Show-Warning -Title 'Elevacao cancelada ou falhou' -Message "Nao foi possivel iniciar os comandos elevados via UAC.`r`n`r`nLog:`r`n$logPath"
        return $false
    }

    if ($null -ne $process -and $process.ExitCode -eq 0) {
        Remove-TemporaryCmdFile -Path $CommandScript
        return $true
    }

    $exitCode = 1

    if ($null -ne $process) {
        $exitCode = $process.ExitCode
    }

    $logPath = Write-FailureLog -Prefix 'manual-elevate' -ExitCode $exitCode -Output "A execucao elevada via UAC terminou com codigo $exitCode."
    Show-Warning -Title 'Erro na execucao elevada' -Message "A execucao elevada via UAC terminou com codigo $exitCode.`r`n`r`nLog:`r`n$logPath"
    return $false
}

function Start-ConfiguredCommands {
    param([System.Collections.Generic.List[string]]$Commands, [bool]$Admin, [bool]$Elevate)

    try {
        $tempScript = New-CommandScript -Commands $Commands -Prefix 'manual-botao'

        if ($false -eq $tempScript) {
            return $false
        }
    } catch {
        Show-Warning -Title 'Erro ao preparar comandos' -Message "Nao foi possivel criar o arquivo temporario.`r`n`r`n$($_.Exception.Message)"
        return $false
    }

    try {
        if ($Elevate) {
            return Start-ElevatedUacCommand -CommandScript $tempScript
        }

        if ($Admin) {
            return Start-AdminPsExecCommand -CommandScript $tempScript
        }

        $process = Start-Process -FilePath 'cmd.exe' -ArgumentList @('/c', ('"{0}"' -f $tempScript)) -PassThru -ErrorAction Stop
        $script:RunningProcesses.Add($process)
        return $true
    } catch {
        if ($Admin -or $Elevate) {
            Remove-TemporaryCmdFile -Path $tempScript
        }

        Show-Warning -Title 'Erro ao executar comandos' -Message "Nao foi possivel iniciar os comandos deste botao.`r`n`r`n$($_.Exception.Message)"
        return $false
    }
}

function Remove-FinishedProcesses {
    for ($index = $script:RunningProcesses.Count - 1; $index -ge 0; $index--) {
        $process = $script:RunningProcesses[$index]

        if ($null -eq $process -or $process.HasExited) {
            $script:RunningProcesses.RemoveAt($index)
        }
    }
}

function Wait-RunningProcesses {
    Remove-FinishedProcesses

    if ($script:RunningProcesses.Count -eq 0) {
        return
    }

    Show-Info -Title 'Aguardando comandos' -Message 'A janela sera fechada depois que os comandos em execucao terminarem.'

    foreach ($process in @($script:RunningProcesses.ToArray())) {
        try {
            if ($null -ne $process -and -not $process.HasExited) {
                $process.WaitForExit()
            }
        } catch {
        }
    }

    $script:RunningProcesses.Clear()
}

function Invoke-ButtonConfig {
    param([object]$Button)

    foreach ($path in $Button.VerifyPaths) {
        $expandedPath = Expand-ConfigValue -Value $path

        if (-not (Test-Path -LiteralPath $expandedPath)) {
            Show-Warning -Title 'Arquivo ausente' -Message "Arquivo nao encontrado:`r`n$expandedPath"
            return
        }
    }

    $ok = Start-ConfiguredCommands -Commands $Button.Commands -Admin $Button.Admin -Elevate $Button.Elevate

    if (-not $ok) {
        return
    }

    if (-not [string]::IsNullOrWhiteSpace($Button.Message)) {
        Show-Info -Title 'Concluido' -Message (Expand-ConfigValue -Value $Button.Message)
    }
}

function Add-Button {
    param([System.Windows.Forms.Form]$Form, [string]$Text, [int]$Top, [scriptblock]$Action)

    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.Left = 20
    $button.Top = $Top
    $button.Width = 300
    $button.Height = 35
    $button.Add_Click($Action)
    $Form.Controls.Add($button)
}

$buttonConfigs = Read-ButtonConfigs

if ($buttonConfigs.Count -eq 0) {
    Show-Warning -Title 'Sem botoes' -Message "Nenhum botao valido foi encontrado em:`r`n$ButtonsConfig"
    exit 1
}

[System.Windows.Forms.Application]::EnableVisualStyles()

$buttonHeight = 35
$gap = 10
$top = 20
$formHeight = [Math]::Min(650, [Math]::Max(160, 85 + (($buttonConfigs.Count + 1) * ($buttonHeight + $gap))))

$form = New-Object System.Windows.Forms.Form
$form.Text = 'LABINFO - EQ/UFRJ'
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.MinimizeBox = $true
$form.AutoScroll = $true
$form.Width = 360
$form.Height = $formHeight

$form.Add_FormClosing({
    Wait-RunningProcesses
    Show-ConsoleWindow
}.GetNewClosure())

foreach ($buttonConfig in $buttonConfigs) {
    $configForClick = $buttonConfig
    Add-Button -Form $form -Text $buttonConfig.Title -Top $top -Action {
        Invoke-ButtonConfig -Button $configForClick
    }.GetNewClosure()

    $top += $buttonHeight + $gap
}

Add-Button -Form $form -Text 'Fechar' -Top $top -Action {
    $form.Close()
}.GetNewClosure()

$form.Add_Shown({
    Hide-ConsoleWindow
}.GetNewClosure())

[void]$form.ShowDialog()
