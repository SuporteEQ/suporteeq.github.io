@echo off
setlocal
set "SCRIPT_FILE=%~f0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$path = $env:SCRIPT_FILE; $raw = [IO.File]::ReadAllText($path); $marker = '# POWERSHELL_START'; $idx = $raw.LastIndexOf($marker); if ($idx -lt 0) { throw 'Bloco PowerShell nao encontrado.' }; $code = $raw.Substring($idx + $marker.Length); Invoke-Expression $code"
exit /b %ERRORLEVEL%

# POWERSHELL_START

$WaitSeconds = 3
$TriggerKey = [ConsoleKey]::Backspace

$ScriptRoot = Split-Path -Parent $env:SCRIPT_FILE
$AutoScript = Join-Path $ScriptRoot 'auto.bat'
$ManualScript = Join-Path $ScriptRoot 'manual.bat'

function Wait-ForManualMode {
    $deadline = (Get-Date).AddSeconds($WaitSeconds)
    $lastShown = $null
    $canReadConsole = $true

    Write-Host ''
    Write-Host 'Modo automatico sera executado se nenhuma acao for tomada.'
    Write-Host "Pressione $TriggerKey para abrir o modo manual."
    Write-Host ''

    while ((Get-Date) -lt $deadline) {
        if ($canReadConsole) {
            try {
                while ([Console]::KeyAvailable) {
                    $key = [Console]::ReadKey($true)

                    if ($key.Key -eq $TriggerKey) {
                        Write-Host 'Modo manual selecionado.'
                        return $true
                    }
                }
            } catch [InvalidOperationException] {
                $canReadConsole = $false
            }
        }

        $remaining = [Math]::Max(0, [Math]::Ceiling(($deadline - (Get-Date)).TotalSeconds))

        if ($remaining -ne $lastShown) {
            Write-Host "Aguardando... $remaining segundo(s)"
            $lastShown = $remaining
        }

        Start-Sleep -Milliseconds 100
    }

    return $false
}

function Invoke-BatFile {
    param(
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        Write-Host "Arquivo nao encontrado: $Path"
        exit 1
    }

    & $Path
    exit $LASTEXITCODE
}

if (Wait-ForManualMode) {
    Invoke-BatFile -Path $ManualScript
} else {
    Write-Host 'Nenhuma tecla de gatilho pressionada. Executando rotina automatica.'
    Invoke-BatFile -Path $AutoScript
}
