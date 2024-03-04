# Install portable packages

# Double Commander
$DOUBLECMD_VERSION='1.0.11'
$DOUBLECMD_URL="https://github.com/doublecmd/doublecmd/releases/download/v${DOUBLECMD_VERSION}/doublecmd-${DOUBLECMD_VERSION}.x86_64-win64.zip"
$DOUBLECMD_ZIP="${HOME}\Downloads\doublecmd.zip"
$OPT_DIR="C:\opt"
Invoke-WebRequest -URI $DOUBLECMD_URL -OutFile $DOUBLECMD_ZIP
& "${env:ProgramFiles}\7-Zip\7z.exe" x $DOUBLECMD_ZIP "-o$($OPT_DIR)" -aoa -r
rm -Force $DOUBLECMD_ZIP
cp -Force .\setup-devenv\doublecmd\* "${OPT_DIR}\doublecmd\"

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\doublecmd.lnk")
$Shortcut.TargetPath = "${OPT_DIR}\doublecmd\doublecmd.exe"
$Shortcut.Save()