#!/bin/bash
# shellcheck disable=SC1091
# A series of scripts that install packages, ComfyUI, configure and download files and start up apps.
# 0: Package installs - root version (no sudo) for runpod.io
# Use the commands below to download script 0, the rest will be fetched by the scripts.
# wget -q https://raw.githubusercontent.com/jtabox/kustom-kloud/main/runpod.io/0.package-installs.sh && chmod +x 0.package-installs.sh && ./0.package-installs.sh


set -e          # Exit on error
set -u          # Exit on using unset variable
set -o pipefail # Exit on pipe error

export DEBIAN_FRONTEND=noninteractive

# Update, upgrade, install packages and clean up
echo -e "\n::::: Starting package installs :::::\n\n"
# Some basic packages
apt-get update -y &&
apt-get upgrade -y &&
apt-get install -y --no-install-recommends \
    aria2 \
    btop \
    cifs-utils \
    duf \
    espeak-ng \
    ffmpeg \
    git-lfs \
    jq \
    lsof \
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
    autoconf \
    automake \
    cmake \
    gfortran \
    libatlas-base-dev \
    libhdf5-serial-dev \
    libssl-dev \
    build-essential \
    python3-dev \
    libffi-dev \
    libncurses5-dev \
    libbz2-dev \
    liblzma-dev \
    libreadline-dev \
    libsqlite3-dev \
    zlib1g-dev

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

wget -q https://raw.githubusercontent.com/jtabox/kustom-kloud/main/runpod.io/1.files-folders.sh && \
    chown root:root 1.files-folders.sh && \
    chmod +x 1.files-folders.sh

echo -e "\n\n::::: Finished package installs :::::\n"
echo -e "::::: Next step :::::\n::::: - | ./1.files-folders.sh | - to set up files and folders :::::\n"