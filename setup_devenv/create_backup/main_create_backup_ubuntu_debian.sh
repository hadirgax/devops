#!/bin/bash

set -e

BACKUP_FILE="${BACKUP_FILE}"
USERNAME="${USERNAME:-$(id -u -n)}"

function main() {
    create_backup
}

function create_backup() {

    echo;echo ">>>>> Deleting Node Modules... >>>>>"
    cd /workspace \
        && find . -name 'node_modules' -type d -prune -print | xargs du -chs \
        && find . -name 'node_modules' -type d -prune -print -exec rm -rf '{}' \;

    echo;echo ">>>>> Building the Backup File... >>>>>"
    USER_HOME=home/${USERNAME}
    cd / && tar -cpzf /tmp/${BACKUP_FILE} \
        workspace \
        ${USER_HOME}/.bash_history \
        ${USER_HOME}/.condarc \
        ${USER_HOME}/.gitconfig \
        ${USER_HOME}/.gitignore \
        ${USER_HOME}/.zsh_history
        # ${USER_HOME}/.oh-my-zsh/custom \
        # ${USER_HOME}/.zshrc

    # echo;echo ">>>>> Transfering the Backup File... >>>>>"
    # cd / && rsync --archive --verbose --delete ${BACKUP_FILE} ${BACKUP_DIR} | grep failed
    # cp ${BACKUP_FILE} ${BACKUP_DIR}

    # echo;echo ">>>>> Deleting the Backup File in Origin <<<<\n"
    # cd / && rm -rf $mydate-rhel-dev.tar.gz
}

$*
