
$ORIGIN_DIR="setup-devenv\windows\terminal\settings.json"

# location of terminal settings after installation
$DESTINATION_DIR="$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"

cp -Force $ORIGIN_DIR $DESTINATION_DIR