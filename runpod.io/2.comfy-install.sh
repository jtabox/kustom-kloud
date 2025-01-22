#!/bin/bash
# shellcheck disable=SC1091
# A series of scripts that install packages, ComfyUI, configure and download files and start up apps.
# 2: ComfyUI installation - root version (no sudo) for runpod.io
# wget https://raw.githubusercontent.com/jtabox/kustom-kloud/main/runpod.io/2.comfy-install.sh && chmod +x 2.comfy-install.sh

set -e          # Exit on error
set -u          # Exit on using unset variable
set -o pipefail # Exit on pipe error

cecho cyan "\n::::: Starting ComfyUI installation  :::::\n\n"

# Check if /workspace is available
if [ ! -d "/workspace" ]; then
    cecho red "Can't find a /workspace directory! Exiting..."
    exit 1
fi

cd /workspace

if [ -d "/workspace/ComfyUI" ]; then
    cecho yellow "A ComfyUI folder exists already, will not clone."
else
    git clone https://github.com/comfyanonymous/ComfyUI.git && \
    cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git && \
    cecho green "ComfyUI and Manager cloned successfully"
fi


# Moving python3.11 to /workspace/usrlocallib to save space in the main container
# if the storage already has a directory, remove it (it means its a new instance)
cecho orange "Moving python3.11 installation to /workspace ..."
if [ -d "/workspace/usrlocallib" ]; then
    rm -rf /workspace/usrlocallib
fi
mkdir -p /workspace/usrlocallib/python3.11
chmod 755 /workspace/usrlocallib
mv /usr/local/lib/python3.11 /workspace/usrlocallib
ln -s /workspace/usrlocallib/python3.11 /usr/local/lib/python3.11

# Some extra packages (torch v2.4.1+cu124 is already installed, has to be locked otherwise xformers will install a different version)
python -m pip install --upgrade pip
pip install --no-build-isolation flash-attn
pip install xformers torch==2.4.1+cu124 --index-url https://download.pytorch.org/whl/cu124

pip install -r /workspace/ComfyUI/requirements.txt && \
pip install -r /workspace/ComfyUI/custom_nodes/ComfyUI-Manager/requirements.txt && \
pip install comfy-cli

if [ -d "/workspace/ComfyUI" ]; then
    # those exist already, no need to overwrite
    rm /root/comfy.settings.json /root/comfy.templates.json /root/mgr.config.ini
else
    mkdir -p "$COMFYUI_PATH"/user/default/ComfyUI-Manager
    mv /root/comfy.settings.json /root/comfy.templates.json "$COMFYUI_PATH"/user/default
    cp /root/mgr.config.ini "$COMFYUI_PATH"/custom_nodes/ComfyUI-Manager/config.ini
    mv /root/mgr.config.ini "$COMFYUI_PATH"/user/default/ComfyUI-Manager/config.ini
fi

mkdir -p "/root/.config/comfy-cli"

cat <<EOF > /root/.config/comfy-cli/config.ini
[DEFAULT]
enable_tracking = False
default_workspace = $COMFYUI_PATH
default_launch_extras =
recent_workspace = $COMFYUI_PATH

EOF

if ! comfy --skip-prompt which; then
    cecho red "\n\n::::: The comfy command isn't working! :::::\n::::: Check if everything is working manually before proceeding :::::\n"
    cecho yellow "::::: Next step :::::"
    cecho yellow "::::: - | ./3.init-apps.sh | - to initialize ngrok & SyncThing :::::\n"
    exit 1
else
    cecho green "\n\n::::: ComfyUI installation completed successfully :::::\n::::: Default ComfyUI path set successfully as $COMFYUI_PATH :::::\n"
    cecho yellow "::::: Next step :::::"
    cecho yellow "::::: - | ./3.init-apps.sh | - to initialize ngrok & SyncThing :::::\n"
fi