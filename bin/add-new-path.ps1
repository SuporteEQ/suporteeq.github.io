del C:\Windows\System32\eq.cmd

New-Item "C:\suporte-eq\bin" -itemType Directory


[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";C:\suporte-eq\bin",
    [EnvironmentVariableTarget]::Machine)