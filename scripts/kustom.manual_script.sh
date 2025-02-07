#!/bin/bash
# shellcheck disable=SC1091,SC1090

# Initializes a pod after the first time it's started. Must be downloaded and run manually.
# If a storage is already mounted, it won't do much.
# Can either download it as a file and run it:
# wget -qO /tmp/initscript.sh https://raw.githubusercontent.com/jtabox/kustom-kloud/main/scripts/kustom.init_script.sh && chmod +x /tmp/initscript.sh && /tmp/initscript.sh && rm /tmp/initscript.sh
# Or feed it to bash:
# bash <(curl -sSf https://raw.githubusercontent.com/jtabox/kustom-kloud/main/scripts/kustom.init_script.sh)

# Exit on error, pipefail
set -eo pipefail

# Read and source the bash_aliases directly from the repo
source <(curl -sSf https://raw.githubusercontent.com/jtabox/kustom-kloud/main/scripts/rp_root.bash_aliases.sh)

# Set environment variables
export PYTHONUNBUFFERED="True"
export DEBIAN_FRONTEND="noninteractive"
export LANG="C.UTF-8"
export LC_ALL="C.UTF-8"
export PIP_NO_CACHE_DIR='1'
export PIP_ROOT_USER_ACTION='ignore'
export PIP_DISABLE_PIP_VERSION_CHECK='1'

print-header 'warn' 'Upgrading and installing APT packages'

apt-get update
apt-get upgrade -y
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
    zstd
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
    zlib1g-dev

mkdir -p /etc/apt/keyrings

wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg && \
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list && \
chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && \
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list

curl -Lo /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg && \
echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | tee /etc/apt/sources.list.d/syncthing.list

curl -sSLf https://get.openziti.io/tun/package-repos.gpg | gpg --dearmor --output /usr/share/keyrings/openziti.gpg && \
chmod a+r /usr/share/keyrings/openziti.gpg && \
echo "deb [signed-by=/usr/share/keyrings/openziti.gpg] https://packages.openziti.org/zitipax-openziti-deb-stable debian main" | tee /etc/apt/sources.list.d/openziti-release.list >/dev/null

apt-get update
apt-get install -y --no-install-recommends \
    eza \
    ngrok \
    syncthing \
    zrok

apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# More tools!
BATVERSION="0.25.0"
RIPGREPVERSION="14.1.1"
wget https://github.com/sharkdp/bat/releases/download/v"${BATVERSION}"/bat_"${BATVERSION}"_amd64.deb && \
    dpkg -i bat_"${BATVERSION}"_amd64.deb && \
    rm bat_"${BATVERSION}"_amd64.deb

curl -LO https://github.com/BurntSushi/ripgrep/releases/download/"${RIPGREPVERSION}"/ripgrep_"${RIPGREPVERSION}"-1_amd64.deb && \
    dpkg -i ripgrep_"${RIPGREPVERSION}"-1_amd64.deb && \
    rm ripgrep_"${RIPGREPVERSION}"-1_amd64.deb

curl -LsSf https://astral.sh/uv/install.sh | env UV_UNMANAGED_INSTALL="/root/.local/bin" sh

rm -rf /tmp/* /var/tmp/*

print-header 'success' 'APT packages installed successfully'

print-header 'info' 'Running /workspace initialization script'

# Main check if workspace even exists in the first place
if [ ! -d "/workspace" ]; then
    print-header 'error' 'Fatal error!' 'The /workspace directory can not be found! Is the storage volume mounted?' 'Exiting ...'
    exit 1
fi

if [ -f "/workspace/_INSTALL_COMPLETE" ]; then
    # This is created after the first time a fresh volume is initialized
    print-header 'success' '/workspace already initialized, no first-time setup required.'
    FIRST_TIME_INSTALL=0
else
    print-header 'warn' '/workspace not yet initialized, executing first-time setup.'
    FIRST_TIME_INSTALL=1
fi

# Stop jupyter server if it's running, since we'll be moving /usr/local/bin where the jupyter binary is
cecho yellow ":: Stopping any running Jupyter server"
jupyter server stop || true

# The /root, /usr/local/lib/python3.11 installation and /usr/local/bin (has many python executables) will be storaged in /workspace for permanence.
# They are moved (with any existing contents) if it's the first-time setup, and links are created to the original location.
# Otherwise they are deleted and only links are created.

if [ $FIRST_TIME_INSTALL -eq 1 ]; then
    cecho cyan 'Moving and symlinking directories to /workspace'
    mkdir -p /workspace/containerdirs &&
        chmod 755 /workspace/containerdirs
    mv /root /workspace/containerdirs/root
    mv /usr/local/lib/python3.11 /workspace/containerdirs/usrlocallib_py311
    mv /usr/local/bin /workspace/containerdirs/usrlocalbin
else
    cecho cyan 'Deleting and restoring existing symlinks from /workspace'
    rm -rf /root
    rm -rf /usr/local/lib/python3.11
    rm -rf /usr/local/bin
fi

ln -s /workspace/containerdirs/root /root
ln -s /workspace/containerdirs/usrlocallib_py311 /usr/local/lib/python3.11
ln -s /workspace/containerdirs/usrlocalbin /usr/local/bin

for linked_dir in "/root" "/usr/local/lib/python3.11" "/usr/local/bin"; do
    if [ ! -L "$linked_dir" ]; then
        echo "!! Error !! $linked_dir is not a symbolic link!"
        exit 1
    fi
    if ! (cd "$linked_dir" 2>/dev/null); then
        echo "!! Error !! $linked_dir can't be accessed!"
        exit 1
    fi
done

print-header 'success' 'Symlinking completed successfully'

print-header 'info' 'Downloading repo files to designated locations'

get-repo-file 'scripts/rp_root.bash_aliases.sh' /root/.bash_aliases &&
    source /root/.bash_aliases

get-repo-file 'configs/nano-conf.tgz' /root &&
    tar -xzf nano-conf.tgz -C /root/ &&
    rm nano-conf.tgz &&
    chown -R root:root /root/.nanorc /root/.nano

mkdir -p /root/download-lists &&
    get-repo-file 'scripts/comfy.models.sh' /root/download-lists &&
    get-repo-file 'scripts/comfy.nodes.sh' /root/download-lists &&
    get-repo-file 'scripts/extra.models.sh' /root/download-lists

mkdir -p /root/scripts &&
    get-repo-file 'scripts/kustom.init_script.sh' /root/scripts &&
    get-repo-file 'scripts/kustom.manual_script.sh' /root/scripts

get-repo-file 'configs/.screenrc' /root
get-repo-file 'configs/comfy-session.screenrc' /root

mkdir -p /root/prog-configs &&
    get-repo-file 'configs/comfy.settings.json' /root/prog-configs &&
    get-repo-file 'configs/comfy.templates.json' /root/prog-configs &&
    get-repo-file 'configs/comfy-cli.config.ini' /root/prog-configs &&
    get-repo-file 'configs/comfy-manager.config.ini' /root/prog-configs &&
    get-repo-file 'configs/ngrok-config.yml' /root/prog-configs

print-header 'success' 'Repo files fetched successfully'

set +e

if [ $FIRST_TIME_INSTALL -eq 1 ]; then
    # stfu motd
    touch /root/.hushlogin

    print-header 'info' 'Installing ComfyUI and Manager'

    cd /workspace

    git clone https://github.com/comfyanonymous/ComfyUI.git &&
        cd /workspace/ComfyUI/custom_nodes &&
        git clone https://github.com/ltdrdata/ComfyUI-Manager.git &&
        cecho green "ComfyUI and Manager cloned successfully"

    # Install main python packages and comfy
    cecho yellow 'Installing Python dependencies'
    python -m pip install --upgrade pip
    pip install torch==2.5.1+cu124 torchvision torchaudio xformers --index-url https://download.pytorch.org/whl/cu124
    pip install --no-build-isolation flash-attn
    pip install -r /workspace/ComfyUI/requirements.txt
    pip install -r /workspace/ComfyUI/custom_nodes/ComfyUI-Manager/requirements.txt
    pip install comfy-cli

    mkdir -p "$COMFYUI_PATH"/user/default/ComfyUI-Manager
    mv /root/prog-configs/comfy.*.json "$COMFYUI_PATH"/user/default
    cp /root/prog-configs/comfy-manager.config.ini "$COMFYUI_PATH"/custom_nodes/ComfyUI-Manager/config.ini
    mv /root/prog-configs/comfy-manager.config.ini "$COMFYUI_PATH"/user/default/ComfyUI-Manager/config.ini

    mkdir -p "/root/.config/comfy-cli"
    replace-in-file "/root/prog-configs/comfy-cli.config.ini" "__COMFYUI_PATH__" "$COMFYUI_PATH"
    mv /root/prog-configs/comfy-cli.config.ini "/root/.config/comfy-cli/config.ini"

    print-header 'success' 'ComfyUI & Manager installation completed successfully'

    cecho cyan 'Creating zrok, ngrok & SyncThing configurations'

    # zrok
    if [ -z "$ZROK_TOKEN" ]; then
        cecho red "ZROK_TOKEN doesn't seem to be set. Will not be initializing zrok, must be done manually."
    else
        zrok enable "$ZROK_TOKEN" -v -d rp.io
    fi
    cecho green "zrok configuration done"

    # ngrok
    if [ -z "$NGROK_AUTH_TOKEN" ]; then
        cecho red "NGROK_AUTH_TOKEN doesn't seem to be set. Will write template file only - replace manually."
    else
        replace-in-file /root/ngrok-config.yml "__NGROK_AUTH_TOKEN__" "$NGROK_AUTH_TOKEN"
    fi
    mkdir -p /root/.config/ngrok &&
        mv /root/ngrok-config.yml /root/.config/ngrok/ngrok.yml

    cecho green "ngrok configuration done"

    if ! touch /workspace/_INSTALL_COMPLETE; then
        cecho red "IMPORTANT!"
        cecho red "Could not create _INSTALL_COMPLETE file! DO IT MANUALLY, otherwise the setup will run again on next container start!"
        cecho red "IMPORTANT!"
    fi
fi

# Should probably unset PYTHONUNBUFFERED and DEBIAN_FRONTEND
unset PYTHONUNBUFFERED
unset DEBIAN_FRONTEND

print-header 'success' '/workspace initialization completed successfully'

cecho cyan "Probably need to 'source /root/.bash_aliases'"
cecho green "To start the screen session run 'screen -c /root/comfy-session.screenrc -S comfy'"
cecho green "To start the various apps use 'run-syncthing', 'run-ngrok' and 'run-comfy'"
cecho green "To download the models and nodes use 'download-models-from-list /root/download-lists/comfy.models.sh'\nand 'install-nodes-from-list /root/download-lists/comfy.nodes.sh'"
