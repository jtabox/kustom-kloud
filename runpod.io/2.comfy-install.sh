#!/bin/bash
# A series of scripts that install packages, ComfyUI, configure and download files.
# 2: ComfyUI installation - root version (no sudo) for runpod.io

set -e          # Exit on error
set -u          # Exit on using unset variable
set -o pipefail # Exit on pipe error

cecho cyanb "Starting ComfyUI installation ..."

# Check if /workspace is available
if [ ! -d "/workspace" ]; then
    cecho red "Can't find a /workspace directory! Exiting..."
    exit 1
fi

cd /workspace

if [ -d "/workspace/ComfyUI" ]; then
    cecho yellow "A ComfyUI folder exists already! Will only pull changes.\nRemove the folder and re-run this if you want to re-clone and make a fresh install."
    cd ComfyUI && git pull
    exit 0
else
    git clone https://github.com/comfyanonymous/ComfyUI.git
    cecho green "ComfyUI cloned successfully"
fi

cd /workspace/ComfyUI/custom_nodes && git clone https://github.com/ltdrdata/ComfyUI-Manager.git

# Some extra packages (torch v2.4.1+cu124 is already installed, has to be locked otherwise xformers will install a different version)
python -m pip install --upgrade pip
pip install --no-build-isolation flash-attn
pip install xformers torch==2.4.1+cu124 --index-url https://download.pytorch.org/whl/cu124

pip install -r /workspace/ComfyUI/requirements.txt && \
pip install -r /workspace/ComfyUI/custom_nodes/ComfyUI-Manager/requirements.txt && \
pip install comfy-cli

if ! comfy set-default "$COMFYUI_PATH"; then
    cecho red "Failed to set the default ComfyUI path via comfy command!\nCheck if everything is working manually. Exiting..."
    exit 1
else
    cecho green "::::: ComfyUI installation completed successfully. :::::\n::::: Default ComfyUI path set successfully as $COMFYUI_PATH :::::"
fi
