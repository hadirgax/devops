#!/bin/bash

printf "<<<< Define variables <<<<\n"
mydate=$(date +'%Y_%m_%d-%H_%M_%S')
filename=$mydate"-rhel-backup-dev.tar.gz"
backup_path="/path/to/backups/linux/"

printf "<<<< Delete node_modules <<<<\n"
cd ${HOME}/dev \
    && find . -name 'node_modules' -type d -prune -print | xargs du -chs \
    && find . -name 'node_modules' -type d -prune -print -exec rm -rf '{}' \;

printf "<<<< Backup vscode extensions <<<<\n"
cd ${HOME}/ \
    && code --list-extensions >> vs_code_extensions.txt

printf "<<<< Build the backup file <<<<\n"
cd ${HOME}/ \
    && tar -cpzf $filename \
        dev \
        .oh-my-zsh/themes/agnoster.zsh-theme .zshrc \
        .gitconfig .gitignore \
        .stoplight \
        .ssh/id_ed25519 .ssh/id_ed25519.pub \
        .config/Code/User/settings.json \
        vs_code_extensions.txt \
        .yarnrc
    # .oh-my-zsh 

printf "<<<< Transfer the file <<<<\n"
cd ${HOME}/ \
    && rsync --archive --verbose --delete \
        $filename \
        $backup_path \
        | grep failed

printf "<<<< Delete backup files <<<<\n"
cd ${HOME}/ \
    && rm -rf vs_code_extensions.txt
    # && rm -rf $mydate-rhel-dev.tar.gz

printf "Done!"