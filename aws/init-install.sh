#!/bin/bash
# shellcheck disable=SC1091,SC1090

# aws + oci init install script
# https://raw.githubusercontent.com/jtabox/kustom-kloud/main/aws/init-install.sh

# Exit on error, pipefail
set -eo pipefail

# Read and source the bash_aliases directly from the repo for now, will download and setup later
source <(curl -sSf https://raw.githubusercontent.com/jtabox/kustom-kloud/main/aws/bash-aliases.sh)

# Set environment variables
# export PYTHONUNBUFFERED="True"
# export PIP_NO_CACHE_DIR='1'
# export PIP_ROOT_USER_ACTION='ignore'
# export PIP_DISABLE_PIP_VERSION_CHECK='1'
# export DEBIAN_FRONTEND="noninteractive"
export LANG="C.UTF-8"
export LC_ALL="C.UTF-8"

print-header 'warn' 'Upgrading and installing APT packages'

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y --no-install-recommends \
    apt-utils \
    aria2 \
    btop \
    build-essential \
    ca-certificates \
    cifs-utils \
    curl \
    dos2unix \
    duf \
    fzf \
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
    zstd

sudo mkdir -p /etc/apt/keyrings

wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg && \
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list && \
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && \
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list

sudo curl -Lo /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg && \
echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list

curl -sSLf https://get.openziti.io/tun/package-repos.gpg | sudo gpg --dearmor --output /usr/share/keyrings/openziti.gpg && \
sudo chmod a+r /usr/share/keyrings/openziti.gpg && \
echo "deb [signed-by=/usr/share/keyrings/openziti.gpg] https://packages.openziti.org/zitipax-openziti-deb-stable debian main" | sudo tee /etc/apt/sources.list.d/openziti-release.list >/dev/null

sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    eza \
    ngrok \
    syncthing \
    zrok

sudo apt-get autoremove -y
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# More tools!
BATVERSION="0.25.0"
RIPGREPVERSION="14.1.1"
wget https://github.com/sharkdp/bat/releases/download/v"${BATVERSION}"/bat_"${BATVERSION}"_amd64.deb && \
    sudo dpkg -i bat_"${BATVERSION}"_amd64.deb && \
    rm bat_"${BATVERSION}"_amd64.deb

curl -LO https://github.com/BurntSushi/ripgrep/releases/download/"${RIPGREPVERSION}"/ripgrep_"${RIPGREPVERSION}"-1_amd64.deb && \
    sudo dpkg -i ripgrep_"${RIPGREPVERSION}"-1_amd64.deb && \
    rm ripgrep_"${RIPGREPVERSION}"-1_amd64.deb

sudo rm -rf /tmp/* /var/tmp/*

print-header 'success' 'APT packages installed successfully'

print-header 'info' 'Downloading repo files'

get-repo-file 'aws/bash-aliases.sh' /home/ubuntu/.bash_aliases

get-repo-file 'configs/nano-conf.tgz' /home/ubuntu &&
    tar -xzf nano-conf.tgz -C /home/ubuntu/ &&
    rm nano-conf.tgz

print-header 'success' 'Repo files downloaded successfully'

print-header 'info' 'Doing some minor final steps'

set +e

# stfu motd
echo stfu motd > /home/ubuntu/.hushlogin

# Set ownership of everything in home dir to ubuntu
sudo chown -R ubuntu:ubuntu /home/ubuntu

# Should probably unset PYTHONUNBUFFERED and DEBIAN_FRONTEND
unset PYTHONUNBUFFERED
# unset DEBIAN_FRONTEND

print-header 'success' 'init script completed successfully'
print-header 'warn' "Don't forget to 'source ~/.bash_aliases' (or relog)"

