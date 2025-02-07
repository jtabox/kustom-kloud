# Dockerfile for Kustom Docker image for runpod.io

ARG CUDAVERSION="12.5.1"
ARG RELEASETYPE="cudnn-devel"
ARG UBUNTUVERSION="22.04"
ARG STARTERIMAGE="nvcr.io/nvidia/cuda:${CUDAVERSION}-${RELEASETYPE}-ubuntu${UBUNTUVERSION}"

FROM ${STARTERIMAGE} AS base

ARG BATVERSION="0.25.0"
ARG RIPGREPVERSION="14.1.1"
ARG PYTHON_VERSION="3.11"

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

# Set environment variables
ENV SHELL="/bin/bash" \
    PYTHONUNBUFFERED="True" \
    DEBIAN_FRONTEND="noninteractive" \
    LANG="C.UTF-8" \
    LC_ALL="C.UTF-8" \
    PIP_CACHE_DIR='/workspace/.cache/pip' \
    PIP_NO_CACHE_DIR='1' \
    PIP_ROOT_USER_ACTION='ignore' \
    PIP_DISABLE_PIP_VERSION_CHECK='1'

WORKDIR /root

# Do the usual updates-upgrades, basic utils, dev stuff
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        apt-utils \
        aria2 \
        btop \
        ca-certificates \
        cifs-utils \
        curl \
        dos2unix \
        duf \
        espeak-ng \
        ffmpeg \
        git \
        git-lfs \
        gnupg \
        jq \
        lsb-release \
        lsof \
        mc \
        nano \
        ncdu \
        openssh-server \
        openssh-client \
        ranger \
        rsync \
        screen \
        software-properties-common \
        sudo \
        unzip \
        wget \
        zip \
        zstd && \
    apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        build-essential \
        cmake \
        gfortran \
        libatlas-base-dev \
        libblas-dev \
        libbz2-dev \
        libffi-dev \
        libhdf5-serial-dev \
        liblapack-dev \
        liblzma-dev \
        libncurses5-dev \
        libreadline-dev \
        libsm6 \
        libsqlite3-dev \
        libssl-dev \
        make \
        zlib1g-dev && \
    mkdir -p /etc/apt/keyrings && \
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list && \
    chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list && \
    curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && \
    echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list && \
    curl -Lo /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | tee /etc/apt/sources.list.d/syncthing.list && \
    curl -sSLf https://get.openziti.io/tun/package-repos.gpg | gpg --dearmor --output /usr/share/keyrings/openziti.gpg && \
    chmod a+r /usr/share/keyrings/openziti.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/openziti.gpg] https://packages.openziti.org/zitipax-openziti-deb-stable debian main" | tee /etc/apt/sources.list.d/openziti-release.list >/dev/null && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        eza \
        ngrok \
        syncthing \
        zrok

# Python 3.11
RUN if [ -n "${PYTHON_VERSION}" ]; then \
        add-apt-repository ppa:deadsnakes/ppa && \
        apt-get install "python${PYTHON_VERSION}-dev" "python${PYTHON_VERSION}-venv" -y --no-install-recommends && \
        ln -s /usr/bin/python${PYTHON_VERSION} /usr/bin/python && \
        rm /usr/bin/python3 && \
        ln -s /usr/bin/python${PYTHON_VERSION} /usr/bin/python3 && \
        curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
        python get-pip.py && \
        pip install --upgrade --no-cache-dir pip; \
    fi && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
# Additional tools
RUN wget https://github.com/sharkdp/bat/releases/download/v"${BATVERSION}"/bat_"${BATVERSION}"_amd64.deb && \
    dpkg -i bat_"${BATVERSION}"_amd64.deb && \
    rm bat_"${BATVERSION}"_amd64.deb && \
    curl -LO https://github.com/BurntSushi/ripgrep/releases/download/"${RIPGREPVERSION}"/ripgrep_"${RIPGREPVERSION}"-1_amd64.deb && \
    dpkg -i ripgrep_"${RIPGREPVERSION}"-1_amd64.deb && \
    rm ripgrep_"${RIPGREPVERSION}"-1_amd64.deb && \
    curl -LsSf https://astral.sh/uv/install.sh | env UV_UNMANAGED_INSTALL="/root/.local/bin" sh && \
    rm -rf /tmp/* /var/tmp/*

# Copy scripts and configs in /tmp/repofiles, the init script will get them from there when it runs
WORKDIR /

COPY --chown=root:root scripts /tmp/repofiles/scripts
COPY --chown=root:root configs /tmp/repofiles/configs
RUN chmod +x /tmp/repofiles/scripts/*

# HTTP ports:
EXPOSE 7667 8778 9889 54638
# TCP ports:
EXPOSE 22 6556 5445 41648

# Start the container
# ENTRYPOINT ["/bin/bash", "-c", "exec /starter.sh"]
CMD [ "/tmp/repofiles/scripts/kustom.init_script.sh" ]
