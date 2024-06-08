# Setup Windows Development Environment

# WSL2

If you have issues about compatiblility between Windows EOL and Linux EOL format while executing the
`wsl.ps1` script, you can try to run the following commands in PowerShell:

```powershell
(Get-Content ${PATH_TO_SH_FILE}) -join "`n" | Set-Content ${PATH_TO_SH_FILE}
```
