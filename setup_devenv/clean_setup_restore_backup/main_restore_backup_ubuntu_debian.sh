#!/bin/bash

set -e  # exit on error
set -x  # debug trace mode

BACKUP_FILE="${BACKUP_FILE}"
DISTRO="${DISTRO}"
FEATURE_DIR="${FEATURE_DIR}"
INSTALL_OH_MY_ZSH="${INSTALL_OHMYZSH:-"true"}"
USERNAME="${USERNAME:-$(id -u -n)}"

function main {

    # if wsl need to chenge nameserver in file /etc/resolv.conf then uncomment this:
    # set_nameserver
    echo
    echo ">>>>> Begin configuration >>>>>"
    update_and_install

}

function set_nameserver {
    echo
    echo ">>>>> Setting WSL nameserver... >>>>>"
    rm -f /etc/resolv.conf \
        && rsync --archive --verbose --delete ${FEATURE_DIR}/wsl.conf \
        && echo nameserver 8.8.8.8 > /etc/resolv.conf \
        && chattr -f +i /etc/resolv.conf
}


function update_and_install {
    echo
    echo ">>>>> Installing tools... >>>>>"
    install_packages_and_tools

    echo
    echo ">>>>> Installing Latest Version of GIT... >>>>>"
    install_latest_git
    echo ">>>>> Testing git installation... >>>>>"
    git --version

    echo; echo ">>>>> Transfering backup files... >>>>> (SKIPPED)"
    # "rsync --archive --verbose --delete ${BACKUP_FILE} ${HOME}/"

    echo; echo ">>>>> Configuring oh-my-zsh repository... >>>>>"
    configuring_oh_my_zsh

    echo; echo ">>>>> Installing Miniconda... >>>>>"
    install_miniconda

    echo; echo ">>>>> Unpacking backup files... >>>>> (SKIPPED)"
    # sudo mkdir /workspace
    # sudo chown ${USERNAME}:${USERNAME} /workspace
    # tar -xvpzf /tmp/${BACKUP_FILE} -C / --numeric-owner

    echo
    echo ">>>>> Cleaning installation... >>>>>"
    sudo apt-get clean -y && sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
}


function install_packages_and_tools {
    sudo apt-get update -yq && export DEBIAN_FRONTEND=noninteractive \
    && sudo apt-get install -q -y --no-install-recommends \
        apt-transport-https \
        build-essential \
        ca-certificates \
        cmake \
        dirmngr \
        gettext \
        gnupg2 \
        libcurl?-openssl-dev \
        libexpat1-dev \
        libpcre2-dev \
        libssl-dev \
        openssh-client \
        zlib1g-dev \
        zsh \
    && sudo apt-get upgrade -yq
        # bzip2 \# curl \# dconf-cli \# dh-autoreconf \# gstreamer1.0-libav \
        # htop \# install-info \# libatk-bridge2.0-0 \# libcups2-dev \
        # libdbus-glib-1-2 \# libgbm-dev \# libglib2.0-0 \# libgtk-3-0 \
        # libnss3-tools \# libsm6 \# libx11-xcb1 \
        # libxcomposite-dev \# libxext6 \# libxkbcommon-x11-0 \# libxrandr2 \# libxrender1 \
        # libxtst6 \# libz-dev \# net-tools \# netcat \# procps \# rsync \
        # subversion \# tar \# wget \
}


function install_latest_git {
    GIT_VERSION_LIST="$(curl -sSL -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/git/git/tags" | grep -oP '"name":\s*"v\K[0-9]+\.[0-9]+\.[0-9]+"' | tr -d '"' | sort -rV )"
    GIT_VERSION="$(echo "${GIT_VERSION_LIST}" | head -n 1)"
    echo "Downloading source for ${GIT_VERSION}..."
    curl -sL https://github.com/git/git/archive/v${GIT_VERSION}.tar.gz | tar -xzC /tmp 2>&1
    echo "Building..."
    cd /tmp/git-${GIT_VERSION}
    sudo make -s USE_LIBPCRE=YesPlease prefix=/usr/local sysconfdir=/etc all \
        && sudo make -s USE_LIBPCRE=YesPlease prefix=/usr/local sysconfdir=/etc install 2>&1
    sudo rm -rf /tmp/git-${GIT_VERSION}
    sudo rm -rf /var/lib/apt/lists/*
}


function configuring_oh_my_zsh() {
    # Adapted, simplified inline Oh My Zsh! install steps that adds, defaults to a codespaces theme.
    # See https://github.com/ohmyzsh/ohmyzsh/blob/master/tools/install.sh for official script.
    cd ${HOME}
    oh_my_install_dir="${HOME}/.oh-my-zsh"
    echo ${INSTALL_OH_MY_ZSH}
    if [ ! -d "${oh_my_install_dir}" ] && [ "${INSTALL_OH_MY_ZSH}" = "true" ]; then
        echo
        echo ">>>>> Inside if statement oh-my-zsh configuration... >>>>>"
        template_path="${oh_my_install_dir}/templates/zshrc.zsh-template"
        user_rc_file="${HOME}/.zshrc"
        umask g-w,o-w
        mkdir -p ${oh_my_install_dir}
        git clone --depth=1 \
            -c core.eol=lf \
            -c core.autocrlf=false \
            -c fsck.zeroPaddedFilemode=ignore \
            -c fetch.fsck.zeroPaddedFilemode=ignore \
            -c receive.fsck.zeroPaddedFilemode=ignore \
            "https://github.com/ohmyzsh/ohmyzsh" "${oh_my_install_dir}" 2>&1
        # disable autoupdates options
        echo -e "$(cat "${template_path}")\nDISABLE_AUTO_UPDATE=false\nDISABLE_UPDATE_PROMPT=false" > ${user_rc_file}
        # sed -i -e 's/ZSH_THEME=.*/ZSH_THEME="devcontainers"/g' ${user_rc_file}

        ### CAT THIS FILE IN .zshrc
        ######################################
        echo  -e "### >>> CUSTOM CONFIG >>>" >> ${user_rc_file}

        # # set PATH so it includes user's private bin if it exists
        # if [ -d "$HOME/.local/bin" ] ; then
        #     PATH="$HOME/.local/bin:$PATH"
        # fi

        echo  -e "# >>> aliases to ubuntu/windows dev paths >>>" >> ${user_rc_file}
        echo  -e "alias uws='cd ${HOME}/workspace'" >> ${user_rc_file}
        echo  -e "alias dws='cd /mnt/d/workspace'" >> ${user_rc_file}
        echo  -e "alias cws='cd /mnt/c/workspace'" >> ${user_rc_file}
        echo  -e "# <<< aliases to ubuntu/windows dev paths <<<" >> ${user_rc_file}

        echo  -e "# >>> docker aliases >>>" >> ${user_rc_file}
        echo  -e "# alias dstart='sudo service docker start'" >> ${user_rc_file}
        echo  -e "# alias dstart='sudo systemctl start docker'" >> ${user_rc_file}
        echo  -e "alias dbuild='docker build'" >> ${user_rc_file}
        echo  -e "alias dc='docker compose'" >> ${user_rc_file}
        echo  -e "alias dcdown='docker compose down'" >> ${user_rc_file}
        echo  -e "alias dcup='docker compose up'" >> ${user_rc_file}
        echo  -e "alias dexec='docker exec'" >> ${user_rc_file}
        echo  -e "alias dia='docker images -a'" >> ${user_rc_file}
        echo  -e "alias dip='docker image prune'" >> ${user_rc_file}
        echo  -e "alias dlog='docker logs'" >> ${user_rc_file}
        echo  -e "alias dps='docker ps -a'" >> ${user_rc_file}
        echo  -e "alias drm='docker rm -f'" >> ${user_rc_file}
        echo  -e "alias drma='docker rm -f $(dps --filter status=exited -q)'" >> ${user_rc_file}
        echo  -e "alias drmi='docker rmi -f'" >> ${user_rc_file}
        echo  -e "alias drmia='docker rmi -f $(dia -q)'" >> ${user_rc_file}
        echo  -e "alias drun='docker run'" >> ${user_rc_file}
        echo  -e "alias dstart='docker start'" >> ${user_rc_file}
        echo  -e "alias dstop='docker stop'" >> ${user_rc_file}
        echo  -e "alias startd='sudo service docker start'" >> ${user_rc_file}
        echo  -e "alias dvls='docker volume ls'" >> ${user_rc_file}
        echo  -e "alias dvp='docker volume prune'" >> ${user_rc_file}
        echo  -e "alias dvrm='docker volume rm'" >> ${user_rc_file}
        echo  -e "# <<< docker aliases <<<" >> ${user_rc_file}

        # echo ">>>>> Copying oh-my-zsh theme... >>>>>"
        # mkdir -p ${oh_my_install_dir}/custom/themes
        # my_theme_from="${FEATURE_DIR}/zsh-themes/devcontainers.zsh-theme"
        # my_theme_to="${oh_my_install_dir}/custom/themes/devcontainers.zsh-theme"
        # cp -f ${my_theme_from} ${my_theme_to}
        # ln -s ${my_theme_to} "${oh_my_install_dir}/custom/themes/codespaces.zsh-theme"

        # Shrink git while still enabling updates
        cd ${oh_my_install_dir}
        git repack -a -d -f --depth=1 --window=1
        sudo chsh --shell /bin/zsh ${USERNAME}
        # sudo cp -rf "${user_rc_file}" "${oh_my_install_dir}" /root
        # chown -R ${USERNAME}:${USERNAME} "${oh_my_install_dir}" "${user_rc_file}"
    fi
}


function install_miniconda() {
    echo -e "export PATH=/opt/conda/bin:\$PATH" >> "${HOME}/.bashrc"
    echo -e "export PATH=/opt/conda/bin:\$PATH" >> "${HOME}/.zshrc"
    CONDA_VERSION=py311_24.1.2-0
    MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh" && \
    SHA256SUM="3f2e5498e550a6437f15d9cc8020d52742d0ba70976ee8fce4f0daefa3992d2e" && \
    MINICONDA_TMP_FILE=/tmp/miniconda.sh
    wget "${MINICONDA_URL}" -O ${MINICONDA_TMP_FILE} -q && \
    echo "${SHA256SUM} ${MINICONDA_TMP_FILE}" > /tmp/shasum && \
    sha256sum --check --status /tmp/shasum && \
    mkdir -p /opt && \
    sudo bash ${MINICONDA_TMP_FILE} -b -p /opt/conda && \
    rm ${MINICONDA_TMP_FILE} /tmp/shasum && \
    sudo ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.zshrc && \
    echo "conda activate base" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.zshrc && \
    sudo find /opt/conda/ -follow -type f -name '*.a' -delete && \
    sudo find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda update --all && \
    /opt/conda/bin/conda clean -afy
}

function install-golang() {
    wget -O /tmp/go1.21.5.linux-amd64.tar.gz https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
    rm -rf /usr/local/go && sudo tar -C /usr/local -xzf /tmp/go1.21.5.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    go version
}

$*
# main "${@:-}"
