FROM ubuntu:noble

LABEL maintainer="hadirgax"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONFAULTHANDLER=1

# hadolint ignore=DL3008
RUN set -eux; \
    apt-get update -q && \
    apt-get install -q -y --no-install-recommends \
        apt-transport-https \
        bzip2 \
        build-essential \
        ca-certificates \
        curl \
        gettext \
        gnupg \
        graphviz \
        graphviz-dev \
        htop \
        jq \
        libcurl?-openssl-dev \
        libexpat1-dev \
        libfontconfig1 \
        libglib2.0-0 \
        libpcre2-dev \
        libsm6 \
        libssl-dev \
        libxext6 \
        libxrender1 \
        netbase \
        openssh-client \
        procps \
        p7zip-full \
        sq \
        subversion \
        sudo \
        tar \
        wget \
        zip \
        zlib1g-dev \
        zsh \
    && apt-get upgrade -yq \
    && update-ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ARG GIT_VERSION=2.52.0
RUN curl -sL https://github.com/git/git/archive/v${GIT_VERSION}.tar.gz | tar -xzC /tmp 2>&1 && \
    cd /tmp/git-${GIT_VERSION} && \
    mkdir -p /usr/local/share/gitweb && \
    make -s USE_LIBPCRE=YesPlease prefix=/usr/local sysconfdir=/etc all && \
    make -s USE_LIBPCRE=YesPlease prefix=/usr/local sysconfdir=/etc install 2>&1 && \
    rm -rf /tmp/git-${GIT_VERSION} && \
    rm -rf /var/lib/apt/lists/*

ARG USERNAME=devcon
ARG USER_GID=1001
ARG USER_HOME="/home/${USERNAME}"
RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd -s /bin/bash --gid ${USER_GID} -m ${USERNAME} && \
    echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME} && \
    chown -R ${USER_GID}:${USERNAME} ${USER_HOME}

RUN OMZ_DIR=${USER_HOME}/.oh-my-zsh && \
    umask g-w,o-w && \
    mkdir -p "${OMZ_DIR}" && \
    git clone --depth=1 \
        -c core.eol=lf \
        -c core.autocrlf=false \
        -c fsck.zeroPaddedFilemode=ignore \
        -c fetch.fsck.zeroPaddedFilemode=ignore \
        -c receive.fsck.zeroPaddedFilemode=ignore \
        "https://github.com/ohmyzsh/ohmyzsh" "${OMZ_DIR}" 2>&1 && \
    ZSHRC_TEMPLATE_FILE="${OMZ_DIR}/templates/zshrc.zsh-template" && \
    ZSHRC_USER_FILE="${USER_HOME}/.zshrc" && \
    echo "$(cat "${ZSHRC_TEMPLATE_FILE}")\nDISABLE_AUTO_UPDATE=false\nDISABLE_UPDATE_PROMPT=false" > ${ZSHRC_USER_FILE} && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${OMZ_DIR}/custom/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${OMZ_DIR}/custom/plugins/zsh-syntax-highlighting && \
    cd ${OMZ_DIR} && \
    git repack -a -d -f --depth=1 --window=1 && \
    echo "auth sufficient pam_rootok.so" >> /etc/pam.d/chsh && \
    chsh --shell /bin/zsh ${USERNAME} && \
    chown -R ${USER_GID}:${USERNAME} ${USER_HOME}/.zshrc && \
    echo 'zsh' >> ${USER_HOME}/.bashrc

CMD [ "/bin/bash" ]

ENV CONDA_PLUGINS_AUTO_ACCEPT_TOS=yes
ENV PATH=${USER_HOME}/conda/bin:$PATH
ARG CONDA_VERSION=py313_25.11.1-1
ARG MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh"
ARG SHA256SUM="e0b10e050e8928e2eb9aad2c522ee3b5d31d30048b8a9997663a8a460d538cef"


RUN set -x && \
    wget "${MINICONDA_URL}" -O /tmp/miniconda.sh -q && \
    echo "${SHA256SUM} /tmp/miniconda.sh" > /tmp/shasum && \
    sha256sum --check --status /tmp/shasum && \
    bash /tmp/miniconda.sh -b -p ${USER_HOME}/conda && \
    rm /tmp/miniconda.sh /tmp/shasum && \
    ln -s ${USER_HOME}/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    find ${USER_HOME}/conda/ -follow -type f -name '*.a' -delete && \
    find ${USER_HOME}/conda/ -follow -type f -name '*.js.map' -delete && \
    echo '. ${HOME}/conda/etc/profile.d/conda.sh' >> ${USER_HOME}/.zshrc && \
    echo 'conda activate venv' >> ${USER_HOME}/.zshrc && \
    conda update --all -y && \
    conda clean -afy && \
    conda create -n venv -c conda-forge -qy python=3.12 --no-default-packages && \
    chown -R ${USER_GID}:${USERNAME} ${USER_HOME}/conda && \
    chmod -R 0775 ${USER_HOME}/conda
