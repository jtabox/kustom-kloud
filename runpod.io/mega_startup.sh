#!/bin/bash
# shellcheck disable=SC1091

# Megascript that prepares a pod for ComfyUI, with relevant installs and configs.
# Checks for /workspace to decide if this a first time install, or a new instance with previous data.
# Runs as root, no sudo required.

# Download manually at first run:
# wget -q https://raw.githubusercontent.com/jtabox/kustom-kloud/megascript-v2/runpod.io/mega_startup.sh && chmod +x mega_startup.sh && ./mega_startup.sh

# Exit on error, pipefail
set -eo pipefail

# Check what exists
if [ ! -d "/workspace" ]; then
    echo -e "\nFatal error:\nA /workspace directory can't be found, make sure a volume is mounted there. Exiting ...\n"
    exit 1
fi

if [ -f "/workspace/_INSTALL_COMPLETE" ]; then
    # This isn't the first time install
    echo -e "\n\n::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
    echo -e "::::: Found existing installation in /workspace, will only adjust existing files :::::"
    echo -e "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n\n"
    FIRST_TIME_INSTALL=false
else
    echo -e "\n\n::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
    echo -e "::::: No existing installation was found, proceeding with first time setup :::::"
    echo -e "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n\n"
    FIRST_TIME_INSTALL=true
fi

# Move root home and python 3.11 installs to /workspace for permanence, if it's the first time, otherwise just link
if [ $FIRST_TIME_INSTALL ]; then
    # /root
    mkdir -p /workspace/root
    chmod 755 /workspace/root
    mv /root /workspace/root
    # Python 3.11
    mkdir -p /workspace/usrlocallib/python3.11
    chmod 755 /workspace/usrlocallib
    mv /usr/local/lib/python3.11 /workspace/usrlocallib
else
    # Just remove the current versions, they'll be linked to the /workspace versions
    rm -rf /root
    rm -rf /usr/local/lib/python3.11
fi
ln -s /workspace/root /root
ln -s /workspace/usrlocallib/python3.11 /usr/local/lib/python3.11

export DEBIAN_FRONTEND=noninteractive

# System packages must be installed and updated either way
echo -e "\n\n:::::::::::::::::::::::::::::::::::::\n::::: Starting package installs :::::\n:::::::::::::::::::::::::::::::::::::\n\n"
# Update
apt-get update -y && apt-get upgrade -y

# Basic packages
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

# Extra packages from other repos
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

# Direct downloads
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

echo -e "\n\n:::::::::::::::::::::::::::::::::::::\n::::: Finished package installs :::::\n:::::::::::::::::::::::::::::::::::::\n\n"

get_repo_file() {
    echo -e "\nFetching: $1"
    wget -q "https://raw.githubusercontent.com/jtabox/kustom-kloud/megascript-v2/$1" || exit 1
    filename=$(basename "$1")
    chown root:root "$filename" || exit 1
    #if a second arg is passed, make the file executable
    if [ "$#" -ge 2 ]; then
        chmod +x "$filename"
    fi
}

if [ $FIRST_TIME_INSTALL ]; then
    echo -e "\n\n::::::::::::::::::::::::::::::::::::::::::::\n::::: Starting files and folders setup :::::\n::::::::::::::::::::::::::::::::::::::::::::\n\n"

    # Shush
    touch /root/.hushlogin

    # Fetch some files
    cd /root || exit 1

    echo -e "\nFetching: .bash_aliases"
    wget -qO .bash_aliases https://raw.githubusercontent.com/jtabox/kustom-kloud/megascript-v2/runpod.io/root.bash_aliases.sh && \
        chown root:root .bash_aliases && \
        source .bash_aliases

    cecho cyan "\nFetching: nano config files"
    wget -q https://raw.githubusercontent.com/jtabox/kustom-kloud/megascript-v2/common/configs/nano-conf.tgz && \
        tar -xzf nano-conf.tgz -C /root/ && \
        rm nano-conf.tgz && \
        chown -R root:root /root/.nanorc /root/.nano

    cecho cyan "\nFetching: comfy download lists"
    get_repo_file "common/scripts/comfy.nodes"
    get_repo_file "common/scripts/comfy.models"

    cecho cyan "\nFetching: screen and comfy config files"
    get_repo_file "common/configs/.screenrc"
    get_repo_file "common/configs/comfy.screenrc"
    get_repo_file "common/configs/comfy.settings.json"
    get_repo_file "common/configs/comfy.templates.json"
    get_repo_file "common/configs/mgr.config.ini"

    cecho green "\n\n:::::::::::::::::::::::::::::::::::::::::::::::::\n::::: Finished setting up files and folders :::::\n:::::::::::::::::::::::::::::::::::::::::::::::::\n\n"

    cecho cyan "\n\n:::::::::::::::::::::::::::::::\n::::: Installing ComfyUI  :::::\n:::::::::::::::::::::::::::::::\n\n"
    cd /workspace

    git clone https://github.com/comfyanonymous/ComfyUI.git && \
    cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git && \
    cecho green "ComfyUI and Manager cloned successfully"

    # Some extra packages (torch v2.4.1+cu124 is already installed, has to be locked otherwise xformers will install a different version)
    python -m pip install --upgrade pip
    pip install --no-build-isolation flash-attn
    pip install xformers torch==2.4.1+cu124 --index-url https://download.pytorch.org/whl/cu124
    pip install -r /workspace/ComfyUI/requirements.txt && \
    pip install -r /workspace/ComfyUI/custom_nodes/ComfyUI-Manager/requirements.txt && \
    pip install comfy-cli

    mkdir -p "$COMFYUI_PATH"/user/default/ComfyUI-Manager
    mv /root/comfy.settings.json /root/comfy.templates.json "$COMFYUI_PATH"/user/default
    cp /root/mgr.config.ini "$COMFYUI_PATH"/custom_nodes/ComfyUI-Manager/config.ini
    mv /root/mgr.config.ini "$COMFYUI_PATH"/user/default/ComfyUI-Manager/config.ini

    mkdir -p "/root/.config/comfy-cli"
    cat <<EOF > /root/.config/comfy-cli/config.ini
[DEFAULT]
enable_tracking = False
default_workspace = $COMFYUI_PATH
default_launch_extras =
recent_workspace = $COMFYUI_PATH

EOF

    touch /workspace/_INSTALL_COMPLETE
    cecho green "\n\n:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n::::: ComfyUI & Manager installation completed successfully :::::\n:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n\n"

    cecho cyan "\n\n:::::::::::::::::::::::::::::::::::::::::::\n::::: Initializing ngrok & SyncThing  :::::\n:::::::::::::::::::::::::::::::::::::::::::\n\n"

    if [ -z "$NGROK_AUTH_TOKEN" ]; then
        cecho red "NGROK_AUTH_TOKEN must be set in order to write ngrok's configuration!"
        exit 1
    fi

    mkdir -p /root/.config/ngrok

    cat <<EOF > /root/.config/ngrok/ngrok.yml
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

    cecho green "ngrok configuration written successfully"

    # Prepare the scp command using $RUNPOD_TCP_PORT_22 and $RUNPOD_PUBLIC_IP
    scp_command="scp -P $RUNPOD_TCP_PORT_22 -i .ssh_key /path/to/config.xml root@$RUNPOD_PUBLIC_IP:/root/config.xml"
    cecho orange "For the next step, send the SyncThing config file manually via the following command:"
    cecho orange "$scp_command"
    cecho orange "Press Enter to continue afterwards. If no file is uploaded, the script will exit."
    read -r

    if [ ! -f "/root/config.xml" ]; then
        cecho red "Can't find the syncthing.config.xml file! Exiting..."
        exit 1
    else
        mkdir -p /root/.local/state/syncthing
        mv /root/config.xml /root/.local/state/syncthing/config.xml
        cecho green "Syncthing configuration file moved successfully"
    fi
    cecho orange "\n:: To install the initial node collection from file: 'install_multiple_nodes /root/comfy.nodes'"
    cecho orange ":: To install the initial model collection from file: 'download_multiple_models /root/comfy.models'\n"
else
    source /root/.bash_aliases
fi

cecho green "\n\n::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n::::: Initialization completed. Press Enter to start the session :::::\n::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n\n"
read -r

# Start the session
screen -c /root/comfy.screenrc
