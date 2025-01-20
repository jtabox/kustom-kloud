#!/bin/bash
# A series of scripts that install packages, ComfyUI, configure and download files.
# 2: ComfyUI installation - root version (no sudo) for runpod.io

set -e          # Exit on error
set -u          # Exit on using unset variable
set -o pipefail # Exit on pipe error

echo "Starting ComfyUI installation..."

# Check if /workspace is available
if [ ! -d "/workspace" ]; then
    echo "Can't find a /workspace directory! Exiting..."
    exit 1
fi

cd /workspace || exit 1

if [ -d "/workspace/ComfyUI" ]; then
    echo "A ComfyUI folder exists already! Will only pull changes. Remove the folder and re-run this to clone and proceed with the installation."
    cd ComfyUI && git pull
    exit 0
else
    git clone https://github.com/comfyanonymous/ComfyUI.git
    echo "ComfyUI cloned successfully"
fi

cd /workspace/ComfyUI/custom_nodes && git clone https://github.com/ltdrdata/ComfyUI-Manager.git

# Some extra packages (torch v2.4.1+cu124 is already installed, has to be locked otherwise xformers will install a different version)
python -m pip install --no-cache-dir --upgrade pip
pip install --no-cache-dir --no-build-isolation flash-attn
pip install --no-cache-dir xformers torch==2.4.1+cu124 --index-url https://download.pytorch.org/whl/cu124

pip install --no-cache-dir -r /workspace/ComfyUI/requirements.txt && \
pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/ComfyUI-Manager/requirements.txt
pip install --no-cache-dir comfy-cli

comfy set-default /workspace/ComfyUI
