ARG CUDAVERSION="12.5.1"
ARG RELEASETYPE="cudnn-devel"
ARG UBUNTUVERSION="22.04"
ARG STARTERIMAGE="nvcr.io/nvidia/cuda:${CUDAVERSION}-${RELEASETYPE}-ubuntu${UBUNTUVERSION}"

ARG BATVERSION="0.25.0"
ARG RIPGREPVERSION="14.1.1"

FROM ${STARTERIMAGE} AS base

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

ENV SHELL="/bin/bash"
ENV PYTHONUNBUFFERED="True"
ENV DEBIAN_FRONTEND="noninteractive"
ENV LANG="C.UTF-8"
ENV LC_ALL="C.UTF-8"

WORKDIR /

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
        nfs-common \
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
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        python3.11-dev \
        python3.11-venv \
        python3.11-distutils && \
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
        zrok && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

# Some more
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
        python3.11 get-pip.py && \
        rm get-pip.py && \
    python3.11 -m pip install --upgrade pip && \
    wget https://github.com/sharkdp/bat/releases/download/v${BATVERSION}/bat_${BATVERSION}_amd64.deb && \
        dpkg -i bat_${BATVERSION}_amd64.deb && \
        rm bat_${BATVERSION}_amd64.deb && \
    curl -LO https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREPVERSION}/ripgrep_${RIPGREPVERSION}-1_amd64.deb && \
        dpkg -i ripgrep_${RIPGREPVERSION}-1_amd64.deb && \
        rm ripgrep_${RIPGREPVERSION}-1_amd64.deb && \
    curl -LsSf https://astral.sh/uv/install.sh | env UV_UNMANAGED_INSTALL="~/.local/bin" sh && \
    rm -rf /tmp/* /var/tmp/*

