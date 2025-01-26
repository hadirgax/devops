#!/bin/bash

# Get current date
mydate=$(date +'%Y_%m_%d-%H_%M_%S')

# Delete node_modules
cd ${HOME}/dev \
    && find . -name 'node_modules' -type d -prune -print | xargs du -chs \
    && find . -name 'node_modules' -type d -prune -print -exec rm -rf '{}' \;

# # Build the backup file
cd ${HOME}/ \
    && tar -cpzf $mydate-vbox-backup-dev.tar.gz \
        dev \
        .oh-my-zsh/themes/agnoster.zsh-theme .zshrc \
        .gitconfig \
        .gitignore \
        .ssh/id_ed25519 .ssh/id_ed25519.pub \
        .config/Code/User/settings.json
    # .oh-my-zsh 

# transfer the file
backup_path="/path/to/backups/linux/" \ &&
cd ${HOME}/ \
    && rsync --archive --verbose --delete \
        $mydate-vbox-backup-dev.tar.gz \
        $backup_path

echo "Done!"