FROM ubuntu:jammy

LABEL maintainer="hadirgax"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONFAULTHANDLER 1

# hadolint ignore=DL3008
RUN set -eux; \
    apt-get update -q && \
    apt-get install -q -y --no-install-recommends \
        bzip2 \
        build-essential \
        ca-certificates \
        curl \
        gettext \
        gnupg \
        libcurl?-openssl-dev \
        libexpat1-dev \
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

ARG GIT_VERSION=2.44.0
RUN curl -sL https://github.com/git/git/archive/v${GIT_VERSION}.tar.gz | tar -xzC /tmp 2>&1 && \
    cd /tmp/git-${GIT_VERSION} && \
    make -s USE_LIBPCRE=YesPlease prefix=/usr/local sysconfdir=/etc all && \
    make -s USE_LIBPCRE=YesPlease prefix=/usr/local sysconfdir=/etc install 2>&1 && \
    rm -rf /tmp/git-${GIT_VERSION} && \
    rm -rf /var/lib/apt/lists/*

ARG USERNAME=devcon
ARG USER_GID=1000
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
    echo "$(cat "${ZSHRC_TEMPLATE_FILE}")\nDISABLE_AUTO_UPDATE=false\nDISABLE_UPDATE_PROMPT=false" > ${USER_HOME}/.zshrc && \
    cd ${OMZ_DIR} && \
    git repack -a -d -f --depth=1 --window=1 && \
    echo "auth sufficient pam_rootok.so" >> /etc/pam.d/chsh && \
    chsh --shell /bin/zsh ${USERNAME} && \
    chown -R ${USER_GID}:${USERNAME} ${USER_HOME}/.zshrc

CMD [ "/bin/bash" ]

ENV PATH /opt/conda/bin:$PATH
ARG CONDA_VERSION=py311_24.1.2-0
RUN set -x && \
    MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh" && \
    SHA256SUM="3f2e5498e550a6437f15d9cc8020d52742d0ba70976ee8fce4f0daefa3992d2e" && \
    wget "${MINICONDA_URL}" -O /tmp/miniconda.sh -q && \
    echo "${SHA256SUM} /tmp/miniconda.sh" > /tmp/shasum && \
    sha256sum --check --status /tmp/shasum && \
    mkdir -p /opt && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh /tmp/shasum && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ${USER_HOME}/.bashrc && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ${USER_HOME}/.zshrc && \
    echo "conda activate base" >> ${USER_HOME}/.bashrc && \
    echo "conda activate base" >> ${USER_HOME}/.zshrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda update --all -y && \
    /opt/conda/bin/conda clean -afy && \
    chown -R ${USER_GID}:${USERNAME} /opt/conda