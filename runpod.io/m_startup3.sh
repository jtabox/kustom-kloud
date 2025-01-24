#!/bin/bash
# shellcheck disable=SC1091

# Megascript that prepares a pod for ComfyUI, with relevant installs and configs.
# Checks for /workspace to decide if this a first time install, or a new instance with previous data.
# Runs as root, no sudo required.

# Exit on error, pipefail
set -eo pipefail

# Logging function
log() {
    local level=$1
    local message=$2
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    case $level in
        INFO) echo -e "\e[32m[INFO] $timestamp: $message\e[0m" ;;
        WARN) echo -e "\e[33m[WARN] $timestamp: $message\e[0m" ;;
        ERROR) echo -e "\e[31m[ERROR] $timestamp: $message\e[0m" ;;
        *) echo -e "[$level] $timestamp: $message" ;;
    esac
}

# Error handling
trap 'log ERROR "Script failed at line $LINENO"; exit 1' ERR

# Check for /workspace
if [ ! -d "/workspace" ]; then
    log ERROR "A /workspace directory can't be found, make sure a volume is mounted there. Exiting ..."
    exit 1
fi

# Determine if this is a first-time install
if [ -f "/workspace/_INSTALL_COMPLETE" ]; then
    log INFO "Found existing installation in /workspace, will only adjust existing files."
    FIRST_TIME_INSTALL=0
else
    log INFO "No existing installation was found, proceeding with first-time setup."
    FIRST_TIME_INSTALL=1
fi

# Stop Jupyter server if running
log INFO "Stopping any running Jupyter server"
jupyter server stop || true

# Move or link directories
if [ $FIRST_TIME_INSTALL -eq 1 ]; then
    log INFO "Moving /root, /usr/local/lib/python3.11, and /usr/local/bin to /workspace"
    mv /root /workspace
    mkdir -p /workspace/usrlocallib && chmod 755 /workspace/usrlocallib
    mv /usr/local/lib/python3.11 /workspace/usrlocallib
    mkdir -p /workspace/usrlocalbin && chmod 755 /workspace/usrlocalbin
    mv /usr/local/bin /workspace/usrlocalbin
else
    log INFO "Removing /root, /usr/local/lib/python3.11, and /usr/local/bin"
    rm -rf /root /usr/local/lib/python3.11 /usr/local/bin
fi

log INFO "Linking /root, /usr/local/lib/python3.11, and /usr/local/bin to their /workspace folders"
ln -s /workspace/root /root
ln -s /workspace/usrlocallib/python3.11 /usr/local/lib
ln -s /workspace/usrlocalbin/bin /usr/local

# System package installation
log INFO "Starting package installs"
export DEBIAN_FRONTEND=noninteractive

apt-get update -y && apt-get upgrade -y

# Basic packages
log INFO "Installing basic packages"
apt-get install -y --no-install-recommends \
    aria2 btop cifs-utils dos2unix duf espeak-ng ffmpeg git-lfs jq lsof mc ncdu nano ranger rsync screen unzip zip

# Dev packages
log INFO "Installing dev packages"
apt-get install -y --no-install-recommends \
    autoconf automake cmake gfortran libatlas-base-dev libhdf5-serial-dev libssl-dev build-essential python3-dev \
    libffi-dev libncurses5-dev libbz2-dev liblzma-dev libreadline-dev libsqlite3-dev zlib1g-dev

# Extra packages from other repos
log INFO "Installing extra packages from other repos"
mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list
chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list

curl -Lo /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | tee /etc/apt/sources.list.d/syncthing.list

curl -sSLf https://get.openziti.io/tun/package-repos.gpg | gpg --dearmor --output /usr/share/keyrings/openziti.gpg
chmod a+r /usr/share/keyrings/openziti.gpg
tee /etc/apt/sources.list.d/openziti-release.list >/dev/null <<EOF
deb [signed-by=/usr/share/keyrings/openziti.gpg] https://packages.openziti.org/zitipax-openziti-deb-stable debian main
EOF

apt-get update
apt-get install -y --no-install-recommends eza ngrok syncthing zrok

# Direct downloads
log INFO "Installing direct downloads"
wget https://github.com/sharkdp/bat/releases/download/v0.25.0/bat_0.25.0_amd64.deb
dpkg -i bat_0.25.0_amd64.deb
rm bat_0.25.0_amd64.deb

curl -LO https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep_14.1.1-1_amd64.deb
dpkg -i ripgrep_14.1.1-1_amd64.deb
rm ripgrep_14.1.1-1_amd64.deb

curl -Lo /usr/local/bin/ctop https://github.com/LordOverlord/ctop/releases/download/v0.1.8/ctop-linux-amd64
chmod +x /usr/local/bin/ctop

wget -qO- https://astral.sh/uv/install.sh | sh

# Cleanup
log INFO "Cleaning up"
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

log INFO "Finished package installs"

# Fetch and setup files
if [ $FIRST_TIME_INSTALL -eq 1 ]; then
    log INFO "Starting files and folders setup"

    touch /root/.hushlogin

    cd /root || exit 1

    log INFO "Fetching .bash_aliases"
    wget -qO .bash_aliases https://raw.githubusercontent.com/jtabox/kustom-kloud/megascript-v2/runpod.io/root.bash_aliases.sh
    chown root:root .bash_aliases
    source .bash_aliases

    log INFO "Fetching nano config files"
    wget -q https://raw.githubusercontent.com/jtabox/kustom-kloud/megascript-v2/common/configs/nano-conf.tgz
    tar -xzf nano-conf.tgz -C /root/
    rm nano-conf.tgz
    chown -R root:root /root/.nanorc /root/.nano

    log INFO "Fetching ComfyUI download lists"
    wget -q "https://raw.githubusercontent.com/jtabox/kustom-kloud/megascript-v2/common/scripts/comfy.nodes"
    wget -q "https://raw.githubusercontent.com/jtabox/kustom-kloud/megascript-v2/common/scripts/comfy.models"
    wget -q "https://raw.githubusercontent.com/jtabox/kustom-kloud/megascript-v2/common/scripts/extra.models"

    log INFO "Fetching screen and ComfyUI config files"
    wget -q "https://raw.githubusercontent.com/jtabox/kustom-kloud/megascript-v2/common/configs/.screenrc"
    wget -q "https://raw.githubusercontent.com/jtabox/kustom-kloud/megascript-v2/common/configs/comfy.screenrc"
    wget -q "https://raw.githubusercontent.com/jtabox/kustom-kloud/megascript-v2/common/configs/comfy.settings.json"
    wget -q "https://raw.githubusercontent.com/jtabox/kustom-kloud/megascript-v2/common/configs/comfy.templates.json"
    wget -q "https://raw.githubusercontent.com/jtabox/kustom-kloud/megascript-v2/common/configs/mgr.config.ini"

    log INFO "Finished setting up files and folders"

    log INFO "Installing ComfyUI"
    cd /workspace
    git clone https://github.com/comfyanonymous/ComfyUI.git
    cd /workspace/ComfyUI/custom_nodes
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git
    log INFO "ComfyUI and Manager cloned successfully"

    python -m pip install --upgrade pip
    pip install --no-build-isolation flash-attn
    pip install xformers torch==2.4.1+cu124 --index-url https://download.pytorch.org/whl/cu124
    pip install -r /workspace/ComfyUI/requirements.txt
    pip install -r /workspace/ComfyUI/custom_nodes/ComfyUI-Manager/requirements.txt
    pip install comfy-cli

    mkdir -p "$COMFYUI_PATH"/user/default/ComfyUI-Manager
    mv /root/comfy.settings.json /root/comfy.templates.json "$COMFYUI_PATH"/user/default
    cp /root/mgr.config.ini "$COMFYUI_PATH"/custom_nodes/ComfyUI-Manager/config.ini
    mv /root/mgr.config.ini "$COMFYUI_PATH"/user/default/ComfyUI-Manager/config.ini

    mkdir -p "/root/.config/comfy-cli"
    cat <<EOF >/root/.config/comfy-cli/config.ini
[DEFAULT]
enable_tracking = False
default_workspace = $COMFYUI_PATH
default_launch_extras =
recent_workspace = $COMFYUI_PATH
EOF

    log INFO "ComfyUI & Manager installation completed successfully"

    log INFO "Initializing ngrok & SyncThing"
    if [ -z "$NGROK_AUTH_TOKEN" ]; then
        log ERROR "NGROK_AUTH_TOKEN must be set in order to write ngrok's configuration!"
        exit 1
    fi

    mkdir -p /root/.config/ngrok
    cat <<EOF >/root/.config/ngrok/ngrok.yml
version: "3"
agent:
  authtoken: $NGROK_AUTH_TOKEN

tunnels:
  comfy:
    proto: http
    addr: 8188
    domain: "civil-known-bluebird.ngrok-free.app"
    oauth:
      provider: "google"
      allow_emails: ["j.tabox@gmail.com"]
  syncthing:
    proto: http
    addr: 8384
    oauth:
      provider: "google"
      allow_emails: ["j.tabox@gmail.com"]
  jupyter:
    proto: http
    addr: 8888
    oauth:
      provider: "google"
      allow_emails: ["j.tabox@gmail.com"]
EOF

    log INFO "ngrok configuration written successfully"

    scp_command="scp -P $RUNPOD_TCP_PORT_22 -i .ssh_key /path/to/config.xml root@$RUNPOD_PUBLIC_IP:/root/config.xml"
    log WARN "For the next step, send the SyncThing config file manually via the following command:"
    log WARN "$scp_command"
    log WARN "Press Enter to continue afterwards. If no file is uploaded, the script will exit."
    read -r

    if [ ! -f "/root/config.xml" ]; then
        log ERROR "Can't find the syncthing.config.xml file! Exiting..."
        exit 1
    else
        mkdir -p /root/.local/state/syncthing
        mv /root/config.xml /root/.local/state/syncthing/config.xml
        log INFO "Syncthing configuration file moved successfully"
    fi

    touch /workspace/_INSTALL_COMPLETE
    log INFO "To install the initial node collection from file: 'install_multiple_nodes /root/comfy.nodes'"
    log INFO "To install the initial model collection from file: 'download_multiple_models /root/comfy.models'"
else
    source /root/.bash_aliases
fi

log INFO "Initialization completed."