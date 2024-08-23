# Write-Output "`n>>>>> Installing $WSL_DISTRO Distribution... >>>>>"
$WSL_DISTRO="Ubuntu" # opts: Debian/Ubuntu
wsl.exe --unregister $WSL_DISTRO
wsl.exe --install -d $WSL_DISTRO
wsl.exe -s $WSL_DISTRO

# VARIABLES
$DEVOPS_DIR="${env:UserProfile}\workspace\devops"
$FEATURE_WIN_DIR="$DEVOPS_DIR\setup_devenv\windows"
$SETUP_WIN_PATH="$FEATURE_WIN_DIR\setup-wsl2.sh"

# Provide a date to be restored, in the format "yyyyMMdd-HHmmss"
# $BACKUP_FILE="20230211-193753_wsl_backup.tar.gz"
# $BACKUP_ORIGIN="${env:UserProfile}\backups\linux\$BACKUP_FILE"
# $BACKUP_DESTINATION="\\wsl.localhost\$WSL_DISTRO\tmp"

# Write-Output "`n>>>>> Transfering the Backup File from GDrive... >>>>>"
# Copy-Item -Path $BACKUP_ORIGIN -Destination $BACKUP_DESTINATION

$FEATURE_WSL_DIR = $FEATURE_WIN_DIR -replace '\\', '/' -replace 'C:', '/mnt/c'
$FEATURE_WSL_DIR

$SETUP_WSL_PATH = $SETUP_WIN_PATH -replace '\\', '/' -replace 'C:', '/mnt/c'
$SETUP_WSL_PATH

# Write-Output "`n>>> Configuring a new WSL setup..."
# wsl.exe -d $WSL_DISTRO -e bash -c "sed -i -e 's/\r$//' $SETUP_WSL_PATH"
wsl.exe -d $WSL_DISTRO -e bash -c "sudo chmod +x $SETUP_WSL_PATH"
wsl.exe -d $WSL_DISTRO -e bash -c "FEATURE_DIR=$FEATURE_WSL_DIR $SETUP_WSL_PATH main"
    # BACKUP_FILE=$BACKUP_FILE \

Write-Output "`n>>>>> Done! >>>>>"
