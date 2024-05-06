
# install binaries
sudo apt-get install   git
 sudo apt-get update -yq && export DEBIAN_FRONTEND=noninteractive \
    && sudo apt-get install -q -y --no-install-recommends \
        apt-transport-https \
        build-essential \
        ca-certificates \
        curl \
        cmake \
        dirmngr \
        file \
        gettext \
        gnupg2 \
        libcurl?-openssl-dev \
        libexpat1-dev \
        libpcre2-dev \
        libssl-dev \
        openssh-client \
        procps \
        zlib1g-dev \
        zsh \
    && sudo apt-get upgrade -yq

# Install git
GIT_VERSION="2.45.0"
echo "Downloading source for ${GIT_VERSION}..."
curl -sL https://github.com/git/git/archive/v${GIT_VERSION}.tar.gz | tar -xzC /tmp 2>&1
echo "Building..."
cd /tmp/git-${GIT_VERSION}
sudo make -s USE_LIBPCRE=YesPlease prefix=/usr/local sysconfdir=/etc all && \
sudo make -s USE_LIBPCRE=YesPlease prefix=/usr/local sysconfdir=/etc install 2>&1
sudo rm -rf /tmp/git-${GIT_VERSION}
sudo rm -rf /var/lib/apt/lists/*
git config --global credential.helper store

# install miniconda
MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" && \
MINICONDA_TMP_FILE=/tmp/miniconda.sh
wget "${MINICONDA_URL}" -O ${MINICONDA_TMP_FILE} -q && \
mkdir -p /opt && \
sudo bash ${MINICONDA_TMP_FILE} -b -p /opt/conda && \
sudo ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
sudo find /opt/conda/ -follow -type f -name '*.a' -delete && \
sudo find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
/opt/conda/bin/conda update --all && \
/opt/conda/bin/conda clean -afy
conda init bash


# install zsh
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
    git clone https://github.com/zsh-users/zsh-autosuggestions ${oh_my_install_dir}/custom/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${oh_my_install_dir}/custom/plugins/zsh-syntax-highlighting
    echo 'zsh' >> ~/.bashrc
    conda init zsh
fi

# install homebrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bashrc
echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.zshrc
