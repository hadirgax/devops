#!/bin/bash

set -e  # exit on error
set -x  # debug trace mode

function main {
    # if wsl need to chenge nameserver in file /etc/resolv.conf then uncomment this:
    # set_nameserver
    echo;echo ">>>>> Begin configuration >>>>>"
    update_and_install
}

function set_nameserver {
    echo;echo ">>>>> Setting WSL nameserver... >>>>>"
    rm -f /etc/resolv.conf \
        && rsync --archive --verbose --delete ${FEATURE_DIR}/wsl.conf \
        && echo nameserver 8.8.8.8 > /etc/resolv.conf \
        && chattr -f +i /etc/resolv.conf
}


function update_and_install {
    echo;echo ">>>>> Installing tools... >>>>>"
    install_packages_and_tools

    echo;echo ">>>>> Installing Latest Version of GIT... >>>>>"
    install_git
    echo ">>>>> Testing git installation... >>>>>"

    echo;echo ">>>>> Configuring oh-my-zsh repository... >>>>>"
    configuring_oh_my_zsh

    echo;echo ">>>>> Installing Miniconda... >>>>>"
    install_miniconda

    echo;echo ">>>>> Transfering backup files... >>>>> (SKIPPED)"
    # "rsync --archive --verbose --delete ${BACKUP_FILE} ${HOME}/"

    echo;echo ">>>>> Unpacking backup files... >>>>> (SKIPPED)"
    # sudo mkdir /workspace
    # sudo chown ${USER}:${USER} /workspace
    # tar -xvpzf /tmp/${BACKUP_FILE} -C / --numeric-owner

    echo;echo ">>>>> Cleaning installation... >>>>>"
    sudo apt-get clean -y && sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
}


function install_packages_and_tools {
    sudo apt-get update -yq && export DEBIAN_FRONTEND=noninteractive \
    && sudo apt-get install -q -y --no-install-recommends \
        apt-transport-https \
        build-essential \
        ca-certificates \
        curl \
        cmake \
        dirmngr \
        file \
        htop \
        gcc \
        gettext \
        gnupg2 \
        libcurl?-openssl-dev \
        libexpat1-dev \
        libpcre2-dev \
        libssl-dev \
        net-tools \
        openssh-client \
        procps \
        unzip \
        zlib1g-dev \
        zsh \
    && sudo apt-get upgrade -yq
        # bzip2 \# dconf-cli \# dh-autoreconf \# gstreamer1.0-libav \# htop \# install-info \
        # libatk-bridge2.0-0 \# libcups2-dev \# libdbus-glib-1-2 \# libgbm-dev \# libglib2.0-0 \
        # libgtk-3-0 \# libnss3-tools \# libsm6 \# libx11-xcb1 \# libxcomposite-dev \# libxext6 \
        # libxkbcommon-x11-0 \# libxrandr2 \# libxrender1 \# libxtst6 \# libz-dev \# net-tools \
        # netcat \# rsync \# subversion \# tar \# wget
}


function install_git {
    GIT_VERSION="2.48.1" && \
    echo;echo "Downloading source for ${GIT_VERSION}..." && \
    curl -sL https://github.com/git/git/archive/v${GIT_VERSION}.tar.gz | tar -xzC /tmp 2>&1
    echo;echo "Building..."
    cd /tmp/git-${GIT_VERSION} && \
    sudo make -s USE_LIBPCRE=YesPlease prefix=/usr/local sysconfdir=/etc all && \
    sudo make -s USE_LIBPCRE=YesPlease prefix=/usr/local sysconfdir=/etc install 2>&1
    sudo rm -rf /tmp/git-${GIT_VERSION} && \
    sudo rm -rf /var/lib/apt/lists/*
    git --version
    # This configuration ensures that line endings in Git repositories are normalized to LF (Unix-style) endings,
    # git config --global core.autocrlf input
}


function configuring_oh_my_zsh() {
    # Adapted, simplified inline Oh My Zsh! install steps that adds, defaults to a codespaces theme.
    # See https://github.com/ohmyzsh/ohmyzsh/blob/master/tools/install.sh for official script.
    echo ">>>>> Inside if statement oh-my-zsh configuration... >>>>>" && \
    cd ${HOME} && \
    OMZ_DIR="${HOME}/.oh-my-zsh" && \
    umask g-w,o-w && \
    mkdir -p ${OMZ_DIR} && \
    git clone --depth=1 \
        -c core.eol=lf \
        -c core.autocrlf=false \
        -c fsck.zeroPaddedFilemode=ignore \
        -c fetch.fsck.zeroPaddedFilemode=ignore \
        -c receive.fsck.zeroPaddedFilemode=ignore \
        "https://github.com/ohmyzsh/ohmyzsh" "${OMZ_DIR}" 2>&1 && \
    ZSHRC_TEMPLATE_FILE="${OMZ_DIR}/templates/zshrc.zsh-template" && \
    ZSHRC_USER_FILE="${HOME}/.zshrc" && \
    echo -e "$(cat "${ZSHRC_TEMPLATE_FILE}")\nDISABLE_AUTO_UPDATE=false\nDISABLE_UPDATE_PROMPT=false" > ${ZSHRC_USER_FILE} && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${OMZ_DIR}/custom/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${OMZ_DIR}/custom/plugins/zsh-syntax-highlighting && \
    cd ${OMZ_DIR} && \
    git repack -a -d -f --depth=1 --window=1 && \
    # echo "auth sufficient pam_rootok.so" >> /etc/pam.d/chsh && \
    chsh --shell /bin/zsh ${USER} && \
    chown -R ${UID}:${USER} ${ZSHRC_USER_FILE}

    # User aliases
    echo  -e "# >>> docker aliases >>>" >> ${ZSHRC_USER_FILE}
    echo  -e "# alias dstart='sudo service docker start'" >> ${ZSHRC_USER_FILE}
    echo  -e "# alias dstart='sudo systemctl start docker'" >> ${ZSHRC_USER_FILE}
    echo  -e "alias dbuild='docker build'" >> ${ZSHRC_USER_FILE}
    echo  -e "alias dc='docker compose'" >> ${ZSHRC_USER_FILE}
    echo  -e "alias dcdown='docker compose down'" >> ${ZSHRC_USER_FILE}
    echo  -e "alias dcup='docker compose up'" >> ${ZSHRC_USER_FILE}
    echo  -e "alias dexec='docker exec'" >> ${ZSHRC_USER_FILE}
    echo  -e "alias dia='docker images -a'" >> ${ZSHRC_USER_FILE}
    echo  -e "alias dip='docker image prune'" >> ${ZSHRC_USER_FILE}
    echo  -e "alias dlog='docker logs'" >> ${ZSHRC_USER_FILE}
    echo  -e "alias dps='docker ps -a'" >> ${ZSHRC_USER_FILE}
    echo  -e "alias drm='docker rm -f'" >> ${ZSHRC_USER_FILE}
    echo  -e "alias drma='docker rm -f $(dps --filter status=exited -q)'" >> ${ZSHRC_USER_FILE}
    echo  -e "alias drmi='docker rmi -f'" >> ${ZSHRC_USER_FILE}
    echo  -e "alias drmia='docker rmi -f $(dia -q)'" >> ${ZSHRC_USER_FILE}
    echo  -e "alias drun='docker run'" >> ${ZSHRC_USER_FILE}
    echo  -e "alias dstart='docker start'" >> ${ZSHRC_USER_FILE}
    echo  -e "alias dstop='docker stop'" >> ${ZSHRC_USER_FILE}
    echo  -e "alias startd='sudo service docker start'" >> ${ZSHRC_USER_FILE}
    echo  -e "alias dvls='docker volume ls'" >> ${ZSHRC_USER_FILE}
    echo  -e "alias dvp='docker volume prune'" >> ${ZSHRC_USER_FILE}
    echo  -e "alias dvrm='docker volume rm'" >> ${ZSHRC_USER_FILE}
    echo  -e "# <<< docker aliases <<<" >> ${ZSHRC_USER_FILE}
    echo "zsh" >> "${HOME}/.bashrc"
}

function install_miniconda() {
    MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" && \
    MINICONDA_TMP_FILE=/tmp/miniconda.sh && \
    wget "${MINICONDA_URL}" -O ${MINICONDA_TMP_FILE} -q && \
    sudo bash ${MINICONDA_TMP_FILE} -b -p $HOME/conda && \
    sudo chown -R $(echo $USER) $HOME/conda && \
    eval "$($HOME/conda/bin/conda shell.bash hook)" && \
    sudo ln -s $HOME/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    sudo find $HOME/conda/ -follow -type f -name '*.a' -delete && \
    sudo find $HOME/conda/ -follow -type f -name '*.js.map' -delete && \
    conda update --all && \
    conda clean -afy && \
    conda init bash && \
    conda init zsh
}

function install-golang() {
    wget -O /tmp/go1.21.5.linux-amd64.tar.gz https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
    rm -rf /usr/local/go && sudo tar -C /usr/local -xzf /tmp/go1.21.5.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    go version
}


function install-gcloud() {
    curl https://sdk.cloud.google.com > /tmp/install-gcloud.sh
    bash /tmp/install-gcloud.sh --disable_prompts
    exec -l $SHELL
}

function install-firebase() {
    curl https://firebase.tools | bash
    exec -l $SHELL
}

$*
# main "${@:-}"
