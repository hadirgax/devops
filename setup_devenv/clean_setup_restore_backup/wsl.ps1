# VARIABLES
$DEVOPS_DIR="$HOME/workspace/devops"
$FEATURE_DIR="$DEVOPS_DIR/setup_devenv/clean_setup_restore_backup"
$WSL_DISTRO="Ubuntu" # opts: Debian/Ubuntu
$SETUP_FILE="$FEATURE_DIR/main_restore_backup_ubuntu_debian.sh"

# Provide a date to be restored, in the format "yyyyMMdd-HHmmss"
$BACKUP_FILE="20230211-193753_wsl_backup.tar.gz"
$BACKUP_ORIGIN="$HOME/backups/linux/$BACKUP_FILE"
$BACKUP_DESTINATION="\\wsl.localhost\$WSL_DISTRO\tmp"

# Write-Output "`n>>>>> Installing $WSL_DISTRO Distribution... >>>>>"
# wsl.exe --unregister $WSL_DISTRO
# wsl.exe --install -d $WSL_DISTRO
# wsl.exe -s $WSL_DISTRO

# Write-Output "`n>>>>> Transfering the Backup File from GDrive... >>>>>"
# Copy-Item -Path $BACKUP_ORIGIN -Destination $BACKUP_DESTINATION

Write-Output "`n>>> Configuring a new WSL setup..."
wsl.exe -d $WSL_DISTRO -e bash -c "sudo chmod +x $SETUP_FILE && \
    BACKUP_FILE=$BACKUP_FILE \
    DISTRO=$WSL_DISTRO \
    FEATURE_DIR=$FEATURE_DIR \
    $SETUP_FILE main"


Write-Output "`n>>>>> Done! >>>>>"
