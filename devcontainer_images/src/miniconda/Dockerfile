FROM ubuntu:jammy

LABEL maintainer="hadirgax"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# hadolint ignore=DL3008
RUN set -eux; \
    apt-get update -q && \
    apt-get install -q -y --no-install-recommends \
        bzip2 \
        ca-certificates \
        curl \
        git \
        gnupg \
        libglib2.0-0 \
        libsm6 \
        libxext6 \
        libxrender1 \
        netbase \
        openssh-client \
        procps \
        subversion \
        wget \
        zsh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV PATH /opt/conda/bin:$PATH

ARG USERNAME=devcon
ARG USER_HOME="/home/${USERNAME}"
RUN groupadd $USERNAME && useradd -s /bin/bash --gid $USERNAME -m $USERNAME

CMD [ "/bin/bash" ]

RUN set -x && \
    MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" && \
    wget "${MINICONDA_URL}" -O /tmp/miniconda.sh -q && \
    mkdir -p /opt && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ${USER_HOME}/.bashrc && \
    echo "conda activate base" >> ${USER_HOME}/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda update --all && \
    /opt/conda/bin/conda clean -afy

RUN groupadd -r conda --gid 900 && usermod -aG conda ${USERNAME}

RUN chmod =2775 /opt/conda

RUN OMZ_DIR=${USER_HOME}/.oh-my-zsh && \
    ZSHRC_TEMPLATE_FILE="${OMZ_DIR}/templates/zshrc.zsh-template" && \
    ZSHRC_PATH=${USER_HOME}/.zshrc && \
    umask g-w,o-w && \
    mkdir -p "${OMZ_DIR}" && \
    git clone --depth=1 \
        -c core.eol=lf \
        -c core.autocrlf=false \
        -c fsck.zeroPaddedFilemode=ignore \
        -c fetch.fsck.zeroPaddedFilemode=ignore \
        -c receive.fsck.zeroPaddedFilemode=ignore \
        "https://github.com/ohmyzsh/ohmyzsh" "${OMZ_DIR}" 2>&1 && \
    echo "$(cat "${ZSHRC_TEMPLATE_FILE}")\nDISABLE_AUTO_UPDATE=false\nDISABLE_UPDATE_PROMPT=false" > ${ZSHRC_PATH} && \
    cd ${OMZ_DIR} && \
    git repack -a -d -f --depth=1 --window=1 && \
    echo "zsh" >> ${USER_HOME}/.bashrc

# Copy environment.yml (if found) to a temp location so we update the environment. Also
# copy "noop.txt" so the COPY instruction does not fail if no environment.yml exists.
COPY environment.yml* noop.txt /tmp/conda-tmp/
RUN if [ -f "/tmp/conda-tmp/environment.yml" ]; then umask 0002 && /opt/conda/bin/conda env update -n base -f /tmp/conda-tmp/environment.yml; fi \
    && rm -rf /tmp/conda-tmp

USER devcon