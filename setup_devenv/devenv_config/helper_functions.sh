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
        bzip2 \
        ca-certificates \
        curl \
        cmake \
        dh-autoreconf \
        dirmngr \
        file \
        htop \
        icu-devtools \
        jq \
        gcc \
        gettext \
        gnupg2 \
        libcurl4-gnutls-dev \
        libexpat1-dev \
        libfontconfig1 \
        libglib2.0-0 \
        libicu-dev \
        libpcre2-dev \
        libsm6 \
        libssl-dev \
        libxext6 \
        libxrender1 \
        libz-dev \
        netbase \
        net-tools \
        openssh-client \
        p7zip-full \
        procps \
        sq \
        subversion \
        sudo \
        tar \
        unzip \
        wget \
        zip \
        zlib1g-dev \
        zsh \
    && sudo apt-get upgrade -yq \
    && sudo update-ca-certificates \
    && sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/*
        # dconf-cli \# gstreamer1.0-libav \# install-info \# libatk-bridge2.0-0 \
        # libcups2-dev \# libdbus-glib-1-2 \# libgbm-dev \# libgtk-3-0 \# libnss3-tools \
        # libx11-xcb1 \# libxcomposite-dev \# libxkbcommon-x11-0 \# libxrandr2 \
        # libxtst6 \# netcat \# rsync \
}

function install_rust {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
}

function install_git {
    local GIT_VERSION=$(curl -s https://git-scm.com/ | grep -oP 'class="version">\K[0-9.]+' | head -n 1)
    local CURRENT_GIT_VERSION=$(git --version)
    if [ "${CURRENT_GIT_VERSION}" != "git version ${GIT_VERSION}" ]; then
        echo;echo ">>> Downloading source for ${GIT_VERSION}..." && \
        curl -sL https://github.com/git/git/archive/v${GIT_VERSION}.tar.gz | tar -xzC /tmp 2>&1
        echo;echo ">>> Building Git..." && \
        cd /tmp/git-${GIT_VERSION} && \
        make -s USE_LIBPCRE=YesPlease prefix=/usr/local sysconfdir=/etc all && \
        sudo make -s USE_LIBPCRE=YesPlease prefix=/usr/local sysconfdir=/etc install 2>&1 && \
        sudo rm -rf /tmp/git-${GIT_VERSION} && \
        sudo rm -rf /var/lib/apt/lists/*
    else
        echo;echo ">>> Git version ${GIT_VERSION} is already installed."
    fi  
    git config --global core.autocrlf input && \
    git --version
}

function install_docker_engine() {
    echo ">>> Installing Docker Engine..."
    
    if command -v docker &> /dev/null; then
        echo ">>> Docker is already installed, skipping installation."
    else
        echo ">>> Installing Docker Engine..."
        sudo apt-get update -y
        sudo apt-get install -y ca-certificates curl
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc

        sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

        sudo apt-get update -y
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    fi

    # Add user to docker group idempotently
    if ! getent group docker > /dev/null; then
        sudo groupadd docker
    fi
    
    if ! groups ${USER} | grep -q "\bdocker\b"; then
        echo ">>> Adding ${USER} to docker group..."
        sudo usermod -aG docker ${USER}
        echo ">>> NOTE: You will need to log out and log back in (or restart your WSL session) for the group changes to take effect."
    else
        echo ">>> User ${USER} is already in the docker group."
    fi

    # Ensure docker service is enabled
    # TODO: check if this systemctl is correctly done for wsl2
    if command -v systemctl &> /dev/null; then
        echo ">>> Enabling docker and containerd services..."
        sudo systemctl enable docker.service || true
        sudo systemctl enable containerd.service || true
        sudo systemctl start docker.service || true
    else
        echo ">>> systemctl not found, starting docker service..."
        sudo service docker start || true
    fi
    echo ">>> Running Docker test image..."
    docker run hello-world
    echo ">>> Docker setup complete"
}

function install_homebrew {
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
    test -d ~/.linuxbrew && sudo eval "$(~/.linuxbrew/bin/brew shellenv)"
    test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
}

function install_miniconda {
    MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" && \
    MINICONDA_SHA256SUM="2284bafb7863a23411b19874d216e237964d4b32dd9beb6807fa8b2d84570961" && \
    MINICONDA_TMP_FILE=/tmp/miniconda.sh && \
    wget "${MINICONDA_URL}" -O ${MINICONDA_TMP_FILE} -q && \
    echo "${MINICONDA_SHA256SUM} ${MINICONDA_TMP_FILE}" > /tmp/shasum && \
    sha256sum --check --status /tmp/shasum && \
    sudo bash ${MINICONDA_TMP_FILE} -b -p $HOME/conda && \
    sudo rm /tmp/miniconda.sh /tmp/shasum && \
    sudo chown -R $(echo $USER) $HOME/conda && \
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

function uninstall_miniconda {
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
    # Download and install fnm:
    curl -o- https://fnm.vercel.app/install | bash -s -- --install-dir $HOME/.fnm --skip-shell --release latest
    # Download and install Node.js:
    local NODE_VERSION=$(curl -s https://nodejs.org/dist/index.json | grep -oP '\{"version":"[^"]+".*?"lts":"[^"]+".*?\}' | head -n 1 | grep -oP '"version":"\K[^"]+')
    $HOME/.fnm/fnm install "${NODE_VERSION}"
    # Verify the Node.js and npm versions:
    echo "NodeJS version: $(node -v)"
    echo "NPM version: $(npm -v)"
}

function install_gurobi_optimizer() {
    # depends on docker
    local GRB_VERSION=$(curl -s "https://api.anaconda.org/package/gurobi/gurobi" | grep -o '"latest_version": "[^"]*' | grep -o '[^"]*$')
    mkdir -p $HOME/.gurobi && \
    sudo chown -R $USER:$USER $HOME/.gurobi && \
    docker create --name temp_container gurobi/optimizer:${GRB_VERSION} && \
    docker cp temp_container:/opt/gurobi/linux $HOME/.gurobi && \
    docker rm temp_container
}

function create_ssh_key() {
    # Usage example:
    #   call create_ssh_key  --email_address=user_email@mail.com  --platform=com.github
    local email_address=""
    local platform=""

    for arg in "$@"; do
        case $arg in
            --email_address=*) email_address="${arg#*=}" ;;
            --platform=*)      platform="${arg#*=}" ;;
            *) echo "Unknown argument: $arg"; return 1 ;;
        esac
    done

    if [[ -z "$email_address" || -z "$platform" ]]; then
        echo "Error: Both --email_address and --platform are required."
        echo "Usage: create_ssh_key --email_address=<email> --platform=<platform>"
        return 1
    fi
    echo ">>> Creating SSH key for ${email_address} on ${platform}..."

    # Resolve hostname from platform name
    local hostname=""
    case "${platform}" in
        github)  hostname="github.com" ;;
        gitlab)  hostname="gitlab.com" ;;
        *)       hostname="${platform}" ;;
    esac
    echo ">>> Creating SSH key for ${email_address} on ${hostname}..."

    # Check if the ssh key already exists
    local ssh_key_file="${HOME}/.ssh/id_ed25519_${platform}"
    if [ -f "${ssh_key_file}" ]; then
        echo ">>> SSH key already exists, skipping installation."
        return 0
    fi

    ssh-keygen -t ed25519 -C "${email_address}" -f "${HOME}/.ssh/id_ed25519_${platform}" -N ""

    # Configure ~/.ssh/config instead of using ssh-agent
    local ssh_config="${HOME}/.ssh/config"
    local key_file="${HOME}/.ssh/id_ed25519_${platform}"

    # Append host block only if it doesn't already exist
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

    # Ensure correct permissions
    chmod 700 "${HOME}/.ssh"
    chmod 600 "${ssh_config}"
    chmod 600 "${key_file}"
    chmod 644 "${key_file}.pub"

    echo ""
    echo ">> Public key (add this to ${platform}):"
    cat "${key_file}.pub"

    # use the ssh host config
    # ssh my-server              # uses the correct key automatically
    # git clone git@github.com:user/repo.git   # uses the github key
}

function install_oh_my_zsh {
    # Adapted, simplified inline Oh My Zsh! install steps that adds, defaults to a codespaces theme.
    # See https://github.com/ohmyzsh/ohmyzsh/blob/master/tools/install.sh for official script.
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo ">>> Inside if statement oh-my-zsh configuration..." && \
        OMZ_DIR="$HOME/.oh-my-zsh" && \
        umask g-w,o-w && \
        mkdir -p ${OMZ_DIR} && \
        git clone --depth=1 \
            -c core.eol=lf \
            -c core.autocrlf=false \
            -c fsck.zeroPaddedFilemode=ignore \
            -c fetch.fsck.zeroPaddedFilemode=ignore \
            -c receive.fsck.zeroPaddedFilemode=ignore \
            "https://github.com/ohmyzsh/ohmyzsh" "${OMZ_DIR}" 2>&1 && \
        git clone https://github.com/zsh-users/zsh-autosuggestions ${OMZ_DIR}/custom/plugins/zsh-autosuggestions && \
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${OMZ_DIR}/custom/plugins/zsh-syntax-highlighting && \
        cd ${OMZ_DIR} && \
        BIN_ZSH_PATH=$(command -v zsh) && \
        git repack -a -d -f --depth=1 --window=1 && \
        sudo chsh --shell ${BIN_ZSH_PATH} ${USER} && \
        chown -R ${UID}:${USER} ${ZSHRC_USER_FILE}
        echo "zsh" >> "${HOME}/.bashrc"
    else
        echo ">>> Oh My Zsh is already installed, skipping installation."
    fi
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
