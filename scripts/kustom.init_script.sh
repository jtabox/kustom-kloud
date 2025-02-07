#!/bin/bash
# shellcheck disable=SC1091
# Called from the Dockerfile's entrypoint, i.e. not during build but when the container is started (since it'll fail if /workspace isn't mounted)
# Checks and if necessary initializes the /workspace mount, adds SSH keys and then goes to sleep for an eternity

# Exit on error, pipefail
set -eo pipefail

# Stupid source, surely this won't backfire
source /tmp/repofiles/scripts/rp_root.bash_aliases.sh

print-header 'info' 'Running initialization script'

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

print-header 'info' 'Moving repo files to designated locations'
# Move all the repo files from /tmp them to their designated locations, overwriting existing ones
cd /root

cp /tmp/repofiles/scripts/rp_root.bash_aliases.sh /root/.bash_aliases &&
    source /root/.bash_aliases

cp /tmp/repofiles/configs/nano-conf.tgz /root/ &&
    tar -xzf nano-conf.tgz -C /root/ &&
    rm nano-conf.tgz &&
    chown -R root:root /root/.nanorc /root/.nano

mkdir -p /root/download-lists &&
    cp /tmp/repofiles/scripts/*.nodes.sh /root/download-lists &&
    cp /tmp/repofiles/scripts/*.models.sh /root/download-lists

mkdir -p /root/scripts &&
    cp /tmp/repofiles/scripts/kustom.init_script.sh /root/scripts &&
    cp /tmp/repofiles/scripts/kustom.manual_script.sh /root/scripts

cp /tmp/repofiles/configs/.screenrc /root/
cp /tmp/repofiles/configs/*.screenrc /root/

mkdir -p /root/prog-configs &&
    cp /tmp/repofiles/configs/comfy.*.json /root/prog-configs &&
    cp /tmp/repofiles/configs/*.config.ini /root/prog-configs &&
    cp /tmp/repofiles/configs/ngrok-config.yml /root/prog-configs

print-header 'success' 'Repo files copied successfully'

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
    pip install -r /workspace/ComfyUI/requirements.txt &&
        pip install -r /workspace/ComfyUI/custom_nodes/ComfyUI-Manager/requirements.txt &&
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

    if ! touch /workspace/_INSTALL_COMPLETE; then
        cecho red "IMPORTANT!"
        cecho red "Could not create _INSTALL_COMPLETE file! DO IT MANUALLY, otherwise the setup will run again on next container start!"
        cecho red "IMPORTANT!"
    fi
fi

print-header 'success' '/workspace initialization completed successfully'

print-header 'info' 'Setting up SSH keys & environment variables'
# Setup ssh
if [[ $PUBLIC_KEY ]]; then
    cecho cyan "Setting up SSH..."
    mkdir -p /root/.ssh
    chmod 700 /root/.ssh
    echo "$PUBLIC_KEY" >> /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    service ssh start
fi

# Export RunPod specific environment variables (but why tho)
cecho cyan "Exporting environment variables..."
printenv | grep '^RUNPOD_' | sort | awk -F = '{ print "export " $1 "=\"" $2 "\"" }' >> /root/rp.io_envs.sh
echo -e '\n\nsource /root/rp.io_envs.sh' >> /root/.bashrc

# Dream of electric sheep
sleep infinity
