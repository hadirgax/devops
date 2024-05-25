
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
        gcc \
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

# Install zsh
cd ${HOME} && \
OMZ_DIR="${HOME}/.oh-my-zsh" && \
echo ">>>>> Inside if statement oh-my-zsh configuration... >>>>>" && \
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
echo "auth sufficient pam_rootok.so" >> /etc/pam.d/chsh && \
chsh --shell /bin/zsh ${USER} && \
chown -R ${UID}:${USER} ${ZSHRC_USER_FILE} && \
echo 'zsh' >> ${HOME}/.bashrc

# Install JetBrains Mono font
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"

# install miniconda
MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" && \
MINICONDA_TMP_FILE=/tmp/miniconda.sh
wget "${MINICONDA_URL}" -O ${MINICONDA_TMP_FILE} -q && \
mkdir -p /opt && \
sudo bash ${MINICONDA_TMP_FILE} -b -p /opt/conda && \
sudo chown -R $(echo $USER) /opt/conda && \
eval "$(/opt/conda/bin/conda shell.bash hook)" && \
sudo ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
sudo find /opt/conda/ -follow -type f -name '*.a' -delete && \
sudo find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
conda update --all && \
conda clean -afy && \
conda init bash && \
conda init zsh

# install homebrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bashrc
echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.zshrc

# install vscode
sudo apt-get install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
rm -f packages.microsoft.gpg
sudo apt install apt-transport-https
sudo apt update
sudo apt install code
