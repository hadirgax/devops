# provide a date to be restored, in the format "yyyy_MM_dd-HH_mm_ss"
$myBackUpName = "2021_04_22-14_21_00-wsl-backup-dev"

# transfer the file
wsl.exe -d Ubuntu -e bash -c "rsync --archive --verbose --delete \
    /path/to/backup/$myBackUpName.tar.gz \
    $HOME"

# Unpack the backup file
wsl.exe -d Ubuntu -e bash -c "cd $HOME \
    && tar -xvpzf $myBackUpName.tar.gz --numeric-owner"