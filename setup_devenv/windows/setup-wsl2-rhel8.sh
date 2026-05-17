#!/bin/bash

set -e  # exit on error
set -x  # debug trace mode

# Ensure the script is not run as root, unless explicitly calling create_user
if [ "$EUID" -eq 0 ] && [ "$1" != "create_user" ]; then
    echo "Error: Please do not execute commands as root."
    echo "If you need to create a user, switch to root and run: $0 create_user <username>"
    echo "Otherwise, run this script as your standard user with sudo privileges."
    exit 1
fi

function create_user {
    local username=$1
    if [ -z "$username" ]; then
        echo "Usage: $0 create_user <username>"
        return 1
    fi
    if [ "$EUID" -ne 0 ]; then
        echo "Error: create_user must be run as root. (e.g. via sudo or root wsl shell)"
        return 1
    fi

    echo;echo ">>>>> Creating user ${username}... >>>>>"
    useradd -m -s /bin/zsh "${username}"
    passwd "${username}"
    usermod -aG wheel "${username}"
    
    # Allow wheel group to use sudo without password
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel_nopasswd
    
    # Set as default WSL user
    cat <<EOF > /etc/wsl.conf
[user]
default=${username}
EOF

    echo ">>>>> User ${username} created and added to wheel group. >>>>>"
    echo ">>>>> Please restart your WSL instance to log in as ${username}. >>>>>"
}

function main {
    # if wsl need to chenge nameserver in file /etc/resolv.conf then uncomment this:
    # set_nameserver
    echo;echo ">>>>> Begin configuration >>>>>"
    update_and_install
}

function set_nameserver {
    echo;echo ">>>>> Setting WSL nameserver... >>>>>"
    sudo rm -f /etc/resolv.conf \
        && sudo rsync --archive --verbose --delete ${FEATURE_DIR}/wsl.conf /etc/ \
        && sudo bash -c 'echo nameserver 8.8.8.8 > /etc/resolv.conf' \
        && sudo chattr -f +i /etc/resolv.conf
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
    sudo dnf clean all && sudo rm -rf /var/cache/dnf /tmp/* /var/tmp/*
}

function install_packages_and_tools {
    sudo dnf update -y
    # Install EPEL repository for extra packages (htop, p7zip, jq, etc.)
    sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm || true
    
    sudo dnf install -y \
        bzip2 \
        ca-certificates \
        curl \
        cmake \
        autoconf \
        automake \
        libtool \
        file \
        htop \
        jq \
        gcc \
        gcc-c++ \
        gettext \
        gettext-devel \
        gnupg2 \
        libcurl-devel \
        expat-devel \
        fontconfig \
        glib2 \
        pcre2-devel \
        libSM \
        openssl-devel \
        libXext \
        libXrender \
        zlib-devel \
        net-tools \
        openssh-clients \
        p7zip \
        procps-ng \
        subversion \
        sudo \
        tar \
        unzip \
        wget \
        zip \
        zsh \
        make \
        util-linux-user
    
    sudo update-ca-trust
    sudo dnf clean all
}

function install_git {
    GIT_VERSION="2.53.0" && \
    echo;echo "Downloading source for ${GIT_VERSION}..." && \
    curl -sL https://github.com/git/git/archive/v${GIT_VERSION}.tar.gz | tar -xzC /tmp 2>&1 && \
    echo;echo "Building Git..." && \
    cd /tmp/git-${GIT_VERSION} && \
    make -s USE_LIBPCRE=YesPlease prefix=/usr/local sysconfdir=/etc all && \
    sudo make -s USE_LIBPCRE=YesPlease prefix=/usr/local sysconfdir=/etc install 2>&1 && \
    sudo rm -rf /tmp/git-${GIT_VERSION} && \
    git --version
    # git config --global core.autocrlf input
}

function configuring_oh_my_zsh() {
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
    sudo chsh --shell /bin/zsh ${USER} && \
    sudo chown -R ${UID}:${USER} ${ZSHRC_USER_FILE}

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
    echo  -e "alias drma='docker rm -f \$(dps --filter status=exited -q)'" >> ${ZSHRC_USER_FILE}
    echo  -e "alias drmi='docker rmi -f'" >> ${ZSHRC_USER_FILE}
    echo  -e "alias drmia='docker rmi -f \$(dia -q)'" >> ${ZSHRC_USER_FILE}
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
    MINICONDA_SHA256SUM="e0b10e050e8928e2eb9aad2c522ee3b5d31d30048b8a9997663a8a460d538cef" && \
    MINICONDA_TMP_FILE=/tmp/miniconda.sh && \
    wget "${MINICONDA_URL}" -O ${MINICONDA_TMP_FILE} -q && \
    echo "${MINICONDA_SHA256SUM} ${MINICONDA_TMP_FILE}" > /tmp/shasum && \
    sha256sum --check --status /tmp/shasum && \
    sudo bash ${MINICONDA_TMP_FILE} -b -p $HOME/conda && \
    sudo rm /tmp/miniconda.sh /tmp/shasum && \
    sudo chown -R $USER:$USER $HOME/conda && \
    sudo ln -s $HOME/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    sudo find $HOME/conda/ -follow -type f -name '*.a' -delete && \
    sudo find $HOME/conda/ -follow -type f -name '*.js.map' -delete && \
    echo '. ${HOME}/conda/etc/profile.d/conda.sh' >> $HOME/.zshrc && \
    echo 'conda activate base' >> $HOME/.zshrc && \
    $HOME/conda/bin/conda config --remove channels defaults && \
    $HOME/conda/bin/conda config --add channels nodefaults && \
    $HOME/conda/bin/conda config --add channels conda-forge && \
    $HOME/conda/bin/conda config --show channels && \
    cp -f $HOME/.condarc $HOME/conda/.condarc && \
    $HOME/conda/bin/conda update --all -y && \
    $HOME/conda/bin/conda clean -afy
}

function uninstall_miniconda() {
    conda deactivate && \
    sudo rm -rf $HOME/conda && \
    sudo rm -rf $HOME/.conda && \
    sudo rm -rf $HOME/.anaconda && \
    sudo rm -rf $HOME/.condarc && \
    sudo rm -rf /etc/profile.d/conda.sh && \
    sed -i '/conda/d' $HOME/.zshrc
}

function install_astral_uv() {
    curl -LsSf https://astral.sh/uv/install.sh | sh
}

function install_nodejs() {
    curl -o- https://fnm.vercel.app/install | bash
    source ~/.zshrc
    fnm install 24
    node -v
    npm -v
}

function install_gemini_cli() {
    npm install -g @google/gemini-cli
}

function install-golang() {
    wget -O /tmp/go1.21.5.linux-amd64.tar.gz https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf /tmp/go1.21.5.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    go version
}

function install-gcloud() {
    curl https://sdk.cloud.google.com > /tmp/install-gcloud.sh
    bash /tmp/install-gcloud.sh --disable_prompts
    exec -l $SHELL
}

function create_ssh_key() {
    local email_address=""
    local platform=""

    for arg in "$@"; do
        case $arg in
            email_address=*) email_address="${arg#*=}" ;;
            platform=*)      platform="${arg#*=}" ;;
        esac
    done

    local hostname=""
    case "${platform}" in
        github)  hostname="github.com" ;;
        gitlab)  hostname="gitlab.com" ;;
        *)       hostname="${platform}" ;;
    esac

    ssh-keygen -t ed25519 -C "${email_address}" -f "${HOME}/.ssh/id_ed25519_${platform}" -N ""

    local ssh_config="${HOME}/.ssh/config"
    local key_file="${HOME}/.ssh/id_ed25519_${platform}"

    if ! grep -q "# --- ${platform} ---" "${ssh_config}" 2>/dev/null; then
        cat >> "${ssh_config}" <<EOF

# --- ${platform} ---
Host ${hostname}
    HostName ${hostname}
    User git
    IdentityFile ${key_file}
    IdentitiesOnly yes
EOF
        echo ">> SSH config entry added for ${platform} (${hostname})"
    else
        echo ">> SSH config entry for ${platform} already exists, skipping."
    fi

    chmod 700 "${HOME}/.ssh"
    chmod 600 "${ssh_config}"
    chmod 600 "${key_file}"
    chmod 644 "${key_file}.pub"

    echo ""
    echo ">> Public key (add this to ${platform}):"
    cat "${key_file}.pub"
}

function install-firebase() {
    curl https://firebase.tools | bash
    exec -l $SHELL
}

$*
# main "${@:-}"
