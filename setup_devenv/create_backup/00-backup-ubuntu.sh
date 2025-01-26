#!/bin/bash

echo "<<<< Defining variables <<<<"
mydate=$(date +'%Y_%m_%d-%H_%M_%S')
filename=$mydate"-ubuntu-backup-dev.tar.gz"
backup_path="/path/to/backups/linux/"

echo "<<<< Deleting node_modules <<<<"
cd ${HOME}/dev \
    && find . -name 'node_modules' -type d -prune -print | xargs du -chs \
    && find . -name 'node_modules' -type d -prune -print -exec rm -rf '{}' \;

echo "<<<< Backing up vscode extensions <<<<"
cd ${HOME}/ \
    && code --list-extensions >> vs_code_extensions.txt

echo "<<<< Building backup file <<<<"
cd ${HOME}/ \
    && tar -cpzf $filename \
        dev \
        .oh-my-zsh/themes/agnoster.zsh-theme \
        .zshrc \
        .gitconfig \
        .gitignore \
        .stoplight \
        .ssh/id_ed25519 \
        .ssh/id_ed25519.pub \
        .config/Code/User/settings.json \
        .config/Code/User/keybindings.json \
        vs_code_extensions.txt \
        .config/doublecmd
    # .oh-my-zsh 

echo "<<<< Transfering the file <<<<"
cd ${HOME}/ \
    && rsync --archive --verbose --delete $filename $backup_path | grep failed

echo "<<<< Deleting backup files <<<<"
cd ${HOME}/ \
    && rm -rf vs_code_extensions.txt \
    && rm -rf $filename

echo "<<< Done! <<<"