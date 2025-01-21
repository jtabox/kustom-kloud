#!/bin/bash
# shellcheck disable=SC1091
# A series of scripts that install packages, ComfyUI, configure and download files and start up apps.
# 4: ComfyUI models installation - root version (no sudo) for runpod.io
# wget https://raw.githubusercontent.com/jtabox/kustom-kloud/main/runpod.io/4.comfy-models.sh && chmod +x 4.comfy-models.sh

# set -e          # Exit on error - we want the script to continue if a node fails to install
set -u          # Exit on using unset variable
set -o pipefail # Exit on pipe error

cecho cyan "\n::::: Starting ComfyUI models installation  :::::\n\n"

if [ -z "$COMFYUI_PATH" ]; then
    cecho red "COMFYUI_PATH must be set to continue. Exiting..."
    exit 1
fi

if [ ! -d "$COMFYUI_PATH" ]; then
    cecho red "Can't find the ComfyUI directory at $COMFYUI_PATH! Exiting..."
    exit 1
fi

if ! command -v getaimodel &> /dev/null; then
    cecho red "The 'getaimodel' command is not available! Exiting..."
    exit 1
fi

if [ ! -f "/root/comfy.models" ]; then
    cecho red "Can't find the comfy.models file! Exiting..."
    exit 1
fi

get_multiple_models "/root/comfy.models"

cecho green "\n\n::::: Finished installing the models :::::"
cecho yellow "::::: Next: run './5.init-apps.sh' to start up ngrok and syncthing :::::\n"