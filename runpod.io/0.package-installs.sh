#!/bin/bash
# A series of scripts that install packages, ComfyUI, configure and download files.
# 0: Package installs - root version (no sudo) for runpod.io

set -e          # Exit on error
set -u          # Exit on using unset variable
set -o pipefail # Exit on pipe error

export DEBIAN_FRONTEND=noninteractive

# Update, upgrade, install packages and clean up
# Some basic packages
apt-get update -y &&
apt-get upgrade -y &&
apt-get install -y --no-install-recommends \
    aria2 \
    btop \
    cifs-utils \
    duf \
    git-lfs \
    jq \
    mc \
    ncdu \
    nano \
    ranger \
    rsync \
    screen \
    unzip \
    zip

# Dev oriented stuff
apt-get install -y --no-install-recommends \
    acl \
    attr \
    autoconf \
    automake \
    cmake \
    ffmpeg \
    file \
    gawk \
    gfortran \
    inotify-tools \
    libatlas-base-dev \
    libavcodec-dev \
    libavfilter-dev \
    libavformat-dev \
    libavutil-dev \
    libblas-dev \
    libhdf5-serial-dev \
    liblapack-dev \
    libpostproc-dev \
    libsm6 \
    libssl-dev \
    libswresample-dev \
    libswscale-dev \
    libv4l-dev \
    libx264-dev \
    libxrender-dev \
    libxvidcore-dev \
    lsof \
    nfs-common \
    python3-cmarkgfm \
    zstd

# Some extra packages from other repos
mkdir -p /etc/apt/keyrings && \

wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg && \
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list && \
chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && \
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list

curl -Lo /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg && \
echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | tee /etc/apt/sources.list.d/syncthing.list

apt-get update && \
apt-get install -y --no-install-recommends \
    eza \
    ngrok \
    syncthing

wget https://github.com/sharkdp/bat/releases/download/v0.25.0/bat_0.25.0_amd64.deb && \
dpkg -i bat_0.25.0_amd64.deb && \
rm bat_0.25.0_amd64.deb

curl -LO https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep_14.1.1-1_amd64.deb && \
dpkg -i ripgrep_14.1.1-1_amd64.deb && \
rm ripgrep_14.1.1-1_amd64.deb

curl -Lo /usr/local/bin/ctop https://github.com/LordOverlord/ctop/releases/download/v0.1.8/ctop-linux-amd64 && \
chmod +x /usr/local/bin/ctop

wget -qO- https://astral.sh/uv/install.sh | sh

# Cleanup
apt-get autoremove -y && \
apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

echo "Package installs done."