@echo off
setlocal
set "SCRIPT_FILE=%~f0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$path = $env:SCRIPT_FILE; $raw = [IO.File]::ReadAllText($path); $marker = '# POWERSHELL_START'; $idx = $raw.LastIndexOf($marker); if ($idx -lt 0) { throw 'Bloco PowerShell nao encontrado.' }; $code = $raw.Substring($idx + $marker.Length); Invoke-Expression $code"
exit /b %ERRORLEVEL%

# POWERSHELL_START

$ScriptRoot = Split-Path -Parent $env:SCRIPT_FILE
$ButtonsConfig = Join-Path $ScriptRoot 'manual-botoes.txt'
$AutoScript = Join-Path $ScriptRoot 'auto.bat'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$RunningProcesses = New-Object System.Collections.Generic.List[object]

function Expand-ConfigValue {
    param(
        [string]$Value
    )

    $expanded = $Value.Replace('%SCRIPT_DIR%', $ScriptRoot)
    $expanded = $expanded.Replace('%AUTO_BAT%', $AutoScript)
    [Environment]::ExpandEnvironmentVariables($expanded)
}

function Show-Warning {
    param(
        [string]$Title,
        [string]$Message
    )

    [System.Windows.Forms.MessageBox]::Show(
        $Message,
        $Title,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    ) | Out-Null
}

function Show-Info {
    param(
        [string]$Title,
        [string]$Message
    )

    [System.Windows.Forms.MessageBox]::Show(
        $Message,
        $Title,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
}

function New-ButtonConfig {
    [PSCustomObject]@{
        Title = ''
        Commands = New-Object System.Collections.Generic.List[string]
        VerifyPaths = New-Object System.Collections.Generic.List[string]
        Admin = $false
        Message = ''
    }
}

function Add-ButtonConfig {
    param(
        [System.Collections.Generic.List[object]]$Buttons,
        [object]$Button
    )

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
    $lineNumber = 0

    foreach ($line in Get-Content -LiteralPath $ButtonsConfig -Encoding Default) {
        $lineNumber++
        $trimmed = $line.Trim()

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

        switch ($key) {
            'titulo' { $current.Title = $value }
            'title' { $current.Title = $value }
            'comando' { $current.Commands.Add($value) }
            'command' { $current.Commands.Add($value) }
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
            'mensagem' { $current.Message = $value }
            'message' { $current.Message = $value }
        }
    }

    Add-ButtonConfig -Buttons $buttons -Button $current
    return $buttons.ToArray()
}

function Split-CommandLine {
    param(
        [string]$Command
    )

    $trimmed = $Command.Trim()

    if ($trimmed -match '^"([^"]+)"\s*(.*)$') {
        return [PSCustomObject]@{
            Target = $matches[1]
            Arguments = $matches[2].Trim()
        }
    }

    if ($trimmed -match '^(\S+)\s*(.*)$') {
        return [PSCustomObject]@{
            Target = $matches[1]
            Arguments = $matches[2].Trim()
        }
    }

    return [PSCustomObject]@{
        Target = ''
        Arguments = ''
    }
}

function Test-CommandTarget {
    param(
        [string]$Target
    )

    if ([string]::IsNullOrWhiteSpace($Target)) {
        return $false
    }

    if ([IO.Path]::IsPathRooted($Target) -and -not (Test-Path -LiteralPath $Target)) {
        Show-Warning -Title 'Arquivo ausente' -Message "Arquivo nao encontrado:`r`n$Target"
        return $false
    }

    return $true
}

function Convert-CommandForBatch {
    param(
        [string]$Command
    )

    $expandedCommand = Expand-ConfigValue -Value $Command
    $parts = Split-CommandLine -Command $expandedCommand

    if (-not (Test-CommandTarget -Target $parts.Target)) {
        return $false
    }

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

function Start-ConfiguredCommands {
    param(
        [System.Collections.Generic.List[string]]$Commands,
        [bool]$Admin
    )

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

    $tempScript = Join-Path $env:TEMP ("manual-botao-{0}.cmd" -f ([guid]::NewGuid().ToString('N')))

    try {
        Set-Content -LiteralPath $tempScript -Value $lines.ToArray() -Encoding Default -ErrorAction Stop
    } catch {
        Show-Warning -Title 'Erro ao preparar comandos' -Message "Nao foi possivel criar o arquivo temporario:`r`n$tempScript`r`n`r`n$($_.Exception.Message)"
        return $false
    }

    $arguments = @('/c', ('"{0}"' -f $tempScript))

    try {
        if ($Admin) {
            Start-Process -FilePath 'cmd.exe' -ArgumentList $arguments -Verb RunAs -Wait -ErrorAction Stop
        } else {
            $process = Start-Process -FilePath 'cmd.exe' -ArgumentList $arguments -PassThru -ErrorAction Stop
            $script:RunningProcesses.Add($process)
        }
    } catch {
        if ($Admin) {
            Show-Warning -Title 'Elevacao cancelada ou falhou' -Message "Nao foi possivel executar este botao como administrador.`r`n`r`n$($_.Exception.Message)"
        } else {
            Show-Warning -Title 'Erro ao executar comandos' -Message "Nao foi possivel iniciar os comandos deste botao.`r`n`r`n$($_.Exception.Message)"
        }

        return $false
    }

    return $true
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
    param(
        [object]$Button
    )

    foreach ($path in $Button.VerifyPaths) {
        $expandedPath = Expand-ConfigValue -Value $path

        if (-not (Test-Path -LiteralPath $expandedPath)) {
            Show-Warning -Title 'Arquivo ausente' -Message "Arquivo nao encontrado:`r`n$expandedPath"
            return
        }
    }

    $ok = Start-ConfiguredCommands -Commands $Button.Commands -Admin $Button.Admin

    if (-not $ok) {
        return
    }

    if (-not [string]::IsNullOrWhiteSpace($Button.Message)) {
        Show-Info -Title 'Concluido' -Message (Expand-ConfigValue -Value $Button.Message)
    }
}

function Add-Button {
    param(
        [System.Windows.Forms.Form]$Form,
        [string]$Text,
        [int]$Top,
        [scriptblock]$Action
    )

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
$form.Text = 'Laboratorio - modo manual'
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.MinimizeBox = $true
$form.AutoScroll = $true
$form.Width = 360
$form.Height = $formHeight

$form.Add_FormClosing({
    Wait-RunningProcesses
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

[void]$form.ShowDialog()
