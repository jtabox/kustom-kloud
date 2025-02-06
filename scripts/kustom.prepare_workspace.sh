#!/bin/bash
# shellcheck disable=SC1091
# This script is called from the Dockerfile towards the end of the build process and is responsible for checking/initializing the /workspace storage mount

# Exit on error, pipefail
set -eo pipefail

# Stupid source, surely this won't backfire
source /tmp/repofiles/scripts/rp_root.bash_aliases.sh

print-header 'info' 'Running /workspace initialization script'

# Check if workspace even exists in the first place
if [ ! -d "/workspace" ]; then
    print-header 'error' 'Fatal error!' 'The /workspace directory can not be found! Is the storage volume mounted?' 'Exiting ...'
    exit 1
fi

if [ -f "/workspace/_INSTALL_COMPLETE" ]; then
    # This is created after the first time a fresh volume is initialized
    print-header 'info' '/workspace has already been initialized. Will only adjust specific files as needed.'
    FIRST_TIME_INSTALL=0
else
    print-header 'info' '/workspace has not been initialized previously. Executing first-time setup.'
    FIRST_TIME_INSTALL=1
fi

# The /root, /usr/local/lib/python3.11 installation and /usr/local/bin (has many python executables) will be storaged in /workspace for permanence.
# They are moved (with any existing contents) if it's the first-time setup, and links are created to the original location.
# Otherwise they are deleted and only links are created.

if [ $FIRST_TIME_INSTALL -eq 1 ]; then
    print-header 'info' 'First-time setup: Moving existing content and creating links for specific directories'
    mkdir -p /workspace/containerdirs &&
        chmod 755 /workspace/containerdirs
    # /root -> /workspace/containerdirs/root
    mv /root /workspace/containerdirs/root
    # python3.11 -> /workspace/containerdirs/usrlocallib_py311
    mv /usr/local/lib/python3.11 /workspace/containerdirs/usrlocallib_py311
    # usr/local/bin -> /workspace/containerdirs/usrlocalbin
    mv /usr/local/bin /workspace/containerdirs/usrlocalbin
else
    print-header 'info' 'Existing install: Removing existing content and creating links for specific directories'
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

print-header 'info' 'Moving repo files to their correct locations'
# Move all the repo files from /tmp them to their correct locations always
cd /root

cp  /tmp/repofiles/scripts/rp_root.bash_aliases.sh /root/.bash_aliases &&
    source /root/.bash_aliases

cp /tmp/repofiles/configs/nano-conf.tgz /root/ &&
    tar -xzf nano-conf.tgz -C /root/ &&
    rm nano-conf.tgz &&
    chown -R root:root /root/.nanorc /root/.nano

mkdir -p /root/download-lists &&
    cp /tmp/repofiles/scripts/*.nodes.sh /root/download-lists &&
    cp /tmp/repofiles/scripts/*.models.sh /root/download-lists

mkdir -p /root/container-scripts &&
    cp /tmp/repofiles/scripts/kustom.*.sh /root/container-scripts

cp /tmp/repofiles/configs/.screenrc /root/
cp /tmp/repofiles/configs/*.screenrc /root/

cp /tmp/repofiles/configs/comfy.*.json /root/
cp /tmp/repofiles/configs/*.config.ini /root/
cp /tmp/repofiles/configs/ngrok-config.yml /root/

# Delete any leftovers for good measure
# rm -rf /tmp/repofiles

print-header 'success' 'Repo files moved successfully'

if [ $FIRST_TIME_INSTALL -eq 1 ]; then
    # stfu motd
    touch /root/.hushlogin

    print-header 'info' 'First-time setup: Installing ComfyUI and Manager'

    cd /workspace

    git clone https://github.com/comfyanonymous/ComfyUI.git &&
        cd /workspace/ComfyUI/custom_nodes &&
        git clone https://github.com/ltdrdata/ComfyUI-Manager.git &&
        cecho green "ComfyUI and Manager cloned successfully"


    # Install main python packages and comfy
    python -m pip install --upgrade pip
    pip install torch==2.5.1+cu124 torchvision torchaudio xformers --index-url https://download.pytorch.org/whl/cu124
    pip install --no-build-isolation flash-attn
    pip install -r /workspace/ComfyUI/requirements.txt &&
        pip install -r /workspace/ComfyUI/custom_nodes/ComfyUI-Manager/requirements.txt &&
        pip install comfy-cli

    mkdir -p "$COMFYUI_PATH"/user/default/ComfyUI-Manager
    mv /root/comfy.settings.json /root/comfy.templates.json "$COMFYUI_PATH"/user/default
    cp /root/comfy-manager.config.ini "$COMFYUI_PATH"/custom_nodes/ComfyUI-Manager/config.ini
    mv /root/comfy-manager.config.ini "$COMFYUI_PATH"/user/default/ComfyUI-Manager/config.ini

    mkdir -p "/root/.config/comfy-cli"
    replace-in-file "/root/comfy-cli.config.ini" "__COMFYUI_PATH__" "$COMFYUI_PATH"
    mv /root/comfy-cli.config.ini "/root/.config/comfy-cli/config.ini"

    print-header 'success' 'ComfyUI & Manager installation completed successfully'

    print-header 'info' 'Creating zrok, ngrok & SyncThing configurations'

    if [ -z "$NGROK_AUTH_TOKEN" ]; then
        cecho red "NGROK_AUTH_TOKEN must be set in order to write ngrok's configuration!"
        exit 1
    fi

    mkdir -p /root/.config/ngrok
    replace-in-file /root/ngrok-config.yml "__NGROK_AUTH_TOKEN__" "$NGROK_AUTH_TOKEN"
    mv /root/ngrok-config.yml /root/.config/ngrok/ngrok.yml

    cecho green "ngrok configuration written successfully"

    # TODO: This must be done in some other way
    # # Prepare the scp command using $RUNPOD_TCP_PORT_22 and $RUNPOD_PUBLIC_IP
    # scp_command="scp -P $RUNPOD_TCP_PORT_22 -i .ssh_key /path/to/config.xml root@$RUNPOD_PUBLIC_IP:/root/config.xml"
    # cecho orange "For the next step, send the SyncThing config file manually via the following command:"
    # cecho orange "$scp_command"
    # cecho orange "Press Enter to continue afterwards. If no file is uploaded, the script will exit."
    # read -r

    # if [ ! -f "/root/config.xml" ]; then
    #     cecho red "Can't find the syncthing.config.xml file! Exiting..."
    #     exit 1
    # else
    #     mkdir -p /root/.local/state/syncthing
    #     mv /root/config.xml /root/.local/state/syncthing/config.xml
    #     cecho green "Syncthing configuration file moved successfully"
    # fi

    touch /workspace/_INSTALL_COMPLETE
fi

print-header 'success' '/workspace initialization completed successfully'

# Setup ssh
if [[ $PUBLIC_KEY ]]; then
    cecho cyan "Setting up SSH..."
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

# Export runpod env vars (not really sure why)
cecho cyan "Exporting environment variables..."
printenv | grep -E '^RUNPOD_|^PATH=|^_=' | awk -F = '{ print "export " $1 "=\"" $2 "\"" }' >> /root/rp.io_envs.sh
echo 'source /root/rp.io_envs.sh' >> ~/.bashrc


sleep infinity
