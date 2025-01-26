###################################################################################################
## CREATE A BACKUP FILE OF WSL CONFIGURATIONS
###################################################################################################

Write-Output "`n>>>>> Defining variables >>>>>"
$DEVOPS_DIR="$HOME/workspace/devops"
$FEATURE_DIR="$DEVOPS_DIR/setup-devenv/create_backup"
$WSL_DISTRO="Debian" # opts: Debian/Ubuntu
$SETUP_FILE="$FEATURE_DIR/main_create_backup_ubuntu_debian.sh"

$BACKUP_DATE = Get-Date -Format "yyyyMMdd-HHmmss"
$BACKUP_FILE="${BACKUP_DATE}_wsl_backup.tar.gz"
$BACKUP_ORIGIN="\\wsl.localhost\Debian\tmp\$BACKUP_FILE"
$BACKUP_DESTINATION="\path\to\backups\linux"

Write-Output "`n>>>>> Creating a WSL Backup... >>>>>"
wsl.exe -d $WSL_DISTRO -e bash -c "sudo chmod +x $SETUP_FILE && \
    BACKUP_FILE=$BACKUP_FILE \
    $SETUP_FILE main"

Write-Output "`n>>>>> Transfering the Backup File to GDrive... >>>>>"
Copy-Item -Path $BACKUP_ORIGIN -Destination $BACKUP_DESTINATION

Write-Output "`n>>>>> Deleting the Backup File in Origin... >>>>>"
Remove-Item -Path $BACKUP_ORIGIN -Force


Write-Output "`n>>>>> Done! >>>>>"
