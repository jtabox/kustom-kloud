#!/bin/bash
# shellcheck disable=SC1091
# A series of scripts that install packages, ComfyUI, configure and download files and start up apps.
# 2: ComfyUI installation - root version (no sudo) for runpod.io
# wget https://raw.githubusercontent.com/jtabox/kustom-kloud/main/runpod.io/2.comfy-install.sh && chmod +x 2.comfy-install.sh

# Exit on error, unset variable, pipefail
set -euo pipefail

cecho cyan "\n:::::::::::::::::::::::::::::::\n::::: Installing ComfyUI  :::::\n:::::::::::::::::::::::::::::::\n\n"

# Check if /workspace is available
if [ ! -d "/workspace" ]; then
    cecho red "Can't find a /workspace directory! Exiting..."
    exit 1
fi

cd /workspace

# if a pod has been initialized previously but shut down and restarted
# the /workspace/ComfyUI folder will exist, together with all the nodes and models
# but the Python installation will be fresh and everything will need to be reinstalled
if [ -d "/workspace/ComfyUI" ]; then
    cecho yellow "Found existing ComfyUI folder, will not clone."
    FIRST_TIME_INSTALL=false
else
    git clone https://github.com/comfyanonymous/ComfyUI.git && \
    cd /workspace/ComfyUI/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git && \
    cecho green "ComfyUI and Manager cloned successfully"
    FIRST_TIME_INSTALL=true
fi


# Moving python3.11 to /workspace/usrlocallib to save space in the main container
# If the storage already has a usrlocallib directory, it's left over from a previous run
# and must be removed? or just link the system python dir there?
cecho orange "Moving system Python 3.11 installation to /workspace ..."
if [ $FIRST_TIME_INSTALL ]; then
    mkdir -p /workspace/usrlocallib/python3.11
    chmod 755 /workspace/usrlocallib
    mv /usr/local/lib/python3.11 /workspace/usrlocallib
else
    rm -rf /usr/local/lib/python3.11
fi

ln -s /workspace/usrlocallib/python3.11 /usr/local/lib/python3.11

# Some extra packages (torch v2.4.1+cu124 is already installed, has to be locked otherwise xformers will install a different version)
if [ $FIRST_TIME_INSTALL ]; then
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
else
    # Those were downloaded in a previous step but exist already in their targets, no need to overwrite
    rm /root/comfy.settings.json /root/comfy.templates.json /root/mgr.config.ini
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