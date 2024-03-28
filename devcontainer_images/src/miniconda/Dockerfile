FROM ubuntu:jammy

LABEL maintainer="hadirgax"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# hadolint ignore=DL3008
RUN set -eux; \
    apt-get update -q; \
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
        tzdata \
    ; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

ENV PATH /opt/conda/bin:$PATH

CMD [ "/bin/bash" ]

RUN set -x && \
    wget "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" -O miniconda.sh -q && \
    mkdir -p /opt && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh shasum && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy

RUN python3 -m pip install --upgrade \
    cryptography==42.0.5 \
    pyopenssl==24.1.0

ARG USERNAME=vscode

RUN groupadd -r conda --gid 900 && usermod -aG conda ${USERNAME}

RUN chmod =2775 /opt/conda

USER root

# Copy environment.yml (if found) to a temp location so we update the environment. Also
# copy "noop.txt" so the COPY instruction does not fail if no environment.yml exists.
COPY environment.yml* noop.txt /tmp/conda-tmp/
RUN if [ -f "/tmp/conda-tmp/environment.yml" ]; then umask 0002 && /opt/conda/bin/conda env update -n base -f /tmp/conda-tmp/environment.yml; fi \
    && rm -rf /tmp/conda-tmp
