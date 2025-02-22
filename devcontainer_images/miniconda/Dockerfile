FROM ubuntu:noble

LABEL maintainer="hadirgax"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1

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
        htop \
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

ARG GIT_VERSION=2.48.1
RUN curl -sL https://github.com/git/git/archive/v${GIT_VERSION}.tar.gz | tar -xzC /tmp 2>&1 && \
    cd /tmp/git-${GIT_VERSION} && \
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
    chmod 0440 /etc/sudoers.d/${USERNAME}

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

ENV PATH ${USER_HOME}/conda/bin:$PATH
ARG CONDA_VERSION=py312_25.1.1-2
ARG MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh"
ARG SHA256SUM="4766d85b5f7d235ce250e998ebb5a8a8210cbd4f2b0fea4d2177b3ed9ea87884"

RUN set -x && \
    wget "${MINICONDA_URL}" -O /tmp/miniconda.sh -q && \
    echo "${SHA256SUM} /tmp/miniconda.sh" > /tmp/shasum && \
    sha256sum --check --status /tmp/shasum && \
    bash /tmp/miniconda.sh -b -p ${USER_HOME}/conda && \
    rm /tmp/miniconda.sh /tmp/shasum && \
    chown -R ${USER_GID}:${USERNAME} ${USER_HOME}/conda && \
    ln -s ${USER_HOME}/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo '. ${HOME}/conda/etc/profile.d/conda.sh' >> ${USER_HOME}/.zshrc && \
    echo 'conda activate base' >> ${USER_HOME}/.zshrc && \
    find ${USER_HOME}/conda/ -follow -type f -name '*.a' -delete && \
    find ${USER_HOME}/conda/ -follow -type f -name '*.js.map' -delete && \
    conda update --all -y && \
    conda clean -afy && \
    chmod 0775 ${USER_HOME}/conda && \
    conda create -n venv -c conda-forge -y --no-default-packages
