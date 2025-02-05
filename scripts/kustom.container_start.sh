#!/bin/bash
# shellcheck disable=SC1091
# This script is called from the Dockerfile as the last step

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
    FIRST_TIME_INSTALL=0
else
    echo -e "\n\n::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
    echo -e "::::: No existing installation was found, proceeding with first time setup :::::"
    echo -e "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n\n"
    FIRST_TIME_INSTALL=1
fi

# Move root home, python 3.11 installs and /usr/local/bin to /workspace for permanence, if it's the first time, otherwise just link

# Stop jupyter server if it's running, since we'll be moving /usr/local/bin where the jupyter binary is
echo ":: Stopping any running Jupyter server"
jupyter server stop || true

if [ $FIRST_TIME_INSTALL -eq 1 ]; then
    echo ":: Moving /root, /usr/local/lib/python3.11 and /usr/local/bin to /workspace"
    # /root
    mv /root /workspace
    # Python 3.11
    mkdir -p /workspace/usrlocallib &&
        chmod 755 /workspace/usrlocallib &&
        mv /usr/local/lib/python3.11 /workspace/usrlocallib
    # usr/local/bin too, since many python packages install binaries there
    mkdir -p /workspace/usrlocalbin &&
        chmod 755 /workspace/usrlocalbin &&
        mv /usr/local/bin /workspace/usrlocalbin
else
    # Just remove the current versions, they'll be linked to the /workspace versions
    echo ":: Removing /root, /usr/local/lib/python3.11 and /usr/local/bin"
    rm -rf /root
    rm -rf /usr/local/lib/python3.11
    rm -rf /usr/local/bin
fi
echo ":: Linking /root, /usr/local/lib/python3.11 and /usr/local/bin to their /workspace folders"
ln -s /workspace/root /root
ln -s /workspace/usrlocallib/python3.11 /usr/local/lib
ln -s /workspace/usrlocalbin/bin /usr/local


get_repo_file() {
    echo -e "\n:: Fetching: $1"
    wget -q "https://raw.githubusercontent.com/jtabox/kustom-kloud/megascript-v2/$1" || exit 1
    filename=$(basename "$1")
    chown root:root "$filename" || exit 1
    #if a second arg is passed, make the file executable
    if [ "$#" -ge 2 ]; then
        chmod +x "$filename"
    fi
}

if [ $FIRST_TIME_INSTALL -eq 1 ]; then
    echo -e "\n\n::::::::::::::::::::::::::::::::::::::::::::\n::::: Starting files and folders setup :::::\n::::::::::::::::::::::::::::::::::::::::::::\n\n"

    # Shush
    touch /root/.hushlogin

    # Fetch some files
    cd /root || exit 1

    echo -e "\n:: Fetching: .bash_aliases"
    wget -qO .bash_aliases https://raw.githubusercontent.com/jtabox/kustom-kloud/megascript-v2/runpod.io/root.bash_aliases.sh &&
        chown root:root .bash_aliases &&
        source .bash_aliases

    cecho cyan "\n:: Fetching: nano config files"
    wget -q https://raw.githubusercontent.com/jtabox/kustom-kloud/megascript-v2/common/configs/nano-conf.tgz &&
        tar -xzf nano-conf.tgz -C /root/ &&
        rm nano-conf.tgz &&
        chown -R root:root /root/.nanorc /root/.nano

    cecho cyan "\n:: Fetching: comfy download lists"
    get_repo_file "common/scripts/comfy.nodes"
    get_repo_file "common/scripts/comfy.models"
    get_repo_file "common/scripts/extra.models"

    cecho cyan "\n:: Fetching: screen and comfy config files"
    get_repo_file "common/configs/.screenrc"
    get_repo_file "common/configs/comfy-session.screenrc"
    get_repo_file "common/configs/comfy.settings.json"
    get_repo_file "common/configs/comfy.templates.json"
    get_repo_file "common/configs/mgr.config.ini"

    cecho green "\n\n:::::::::::::::::::::::::::::::::::::::::::::::::\n::::: Finished setting up files and folders :::::\n:::::::::::::::::::::::::::::::::::::::::::::::::\n\n"

    cecho cyan "\n\n:::::::::::::::::::::::::::::::\n::::: Installing ComfyUI  :::::\n:::::::::::::::::::::::::::::::\n\n"
    cd /workspace

    git clone https://github.com/comfyanonymous/ComfyUI.git &&
        cd /workspace/ComfyUI/custom_nodes &&
        git clone https://github.com/ltdrdata/ComfyUI-Manager.git &&
        cecho green "ComfyUI and Manager cloned successfully"

    # Some extra packages (torch v2.4.1+cu124 is already installed, has to be locked otherwise xformers will install a different version)
    python -m pip install --upgrade pip
    pip install --no-build-isolation flash-attn
    pip install xformers torch==2.4.1+cu124 --index-url https://download.pytorch.org/whl/cu124
    pip install -r /workspace/ComfyUI/requirements.txt &&
        pip install -r /workspace/ComfyUI/custom_nodes/ComfyUI-Manager/requirements.txt &&
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

    cecho green "\n\n:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n::::: ComfyUI & Manager installation completed successfully :::::\n:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n\n"

    cecho cyan "\n\n:::::::::::::::::::::::::::::::::::::::::::\n::::: Initializing ngrok & SyncThing  :::::\n:::::::::::::::::::::::::::::::::::::::::::\n\n"

    if [ -z "$NGROK_AUTH_TOKEN" ]; then
        cecho red "NGROK_AUTH_TOKEN must be set in order to write ngrok's configuration!"
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
    touch /workspace/_INSTALL_COMPLETE
    cecho orange "\n:: To install the initial node collection from file: 'install_multiple_nodes /root/comfy.nodes'"
    cecho orange ":: To install the initial model collection from file: 'download_multiple_models /root/comfy.models'\n"
else
    # All the above are already in /workspace, just source the bash_aliases
    source /root/.bash_aliases
fi

cecho green "\n\n:::::::::::::::::::::::::::::::::::::\n::::: Initialization completed. :::::\n:::::::::::::::::::::::::::::::::::::\n\n"

screen -c /root/comfy-session.screenrc -S comfy

#!/bin/bash
set -e  # Exit the script if any statement returns a non-true return value

# Execute script if exists
execute_script() {
    local script_path=$1
    local script_msg=$2
    if [[ -f ${script_path} ]]; then
        echo "${script_msg}"
        bash "${script_path}"
    fi
}

# Setup ssh
setup_ssh() {
    if [[ $PUBLIC_KEY ]]; then
        echo "Setting up SSH..."
        mkdir -p ~/.ssh
        echo "$PUBLIC_KEY" >> ~/.ssh/authorized_keys
        chmod 700 -R ~/.ssh

         if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
            ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -q -N ''
            echo "RSA key fingerprint:"
            ssh-keygen -lf /etc/ssh/ssh_host_rsa_key.pub
        fi

        if [ ! -f /etc/ssh/ssh_host_dsa_key ]; then
            ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -q -N ''
            echo "DSA key fingerprint:"
            ssh-keygen -lf /etc/ssh/ssh_host_dsa_key.pub
        fi

        if [ ! -f /etc/ssh/ssh_host_ecdsa_key ]; then
            ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -q -N ''
            echo "ECDSA key fingerprint:"
            ssh-keygen -lf /etc/ssh/ssh_host_ecdsa_key.pub
        fi

        if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
            ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -q -N ''
            echo "ED25519 key fingerprint:"
            ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
        fi

        service ssh start

        echo "SSH host keys:"
        for key in /etc/ssh/*.pub; do
            echo "Key: $key"
            ssh-keygen -lf "$key"
        done
    fi
}

# Export runpod env vars (not really sure why)
export_runpod_env_vars() {
    echo "Exporting environment variables..."
    printenv | grep -E '^RUNPOD_|^PATH=|^_=' | awk -F = '{ print "export " $1 "=\"" $2 "\"" }' >> /etc/rp_environment
    echo 'source /etc/rp_environment' >> ~/.bashrc
}

# ---------------------------------------------------------------------------- #
#                               Main Program                                   #
# ---------------------------------------------------------------------------- #

execute_script "/pre_start.sh" "Running pre-start script..."

echo "Pod Started"

setup_ssh
start_jupyter
export_env_vars

execute_script "/post_start.sh" "Running post-start script..."

echo "Start script(s) finished, pod is ready to use."

sleep infinity
