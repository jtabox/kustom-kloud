#!/bin/bash
# A series of scripts that install packages, ComfyUI, configure and download files.
# 3: ComfyUI nodes installation - root version (no sudo) for runpod.io


# set -e          # Exit on error - we want the script to continue if a node fails to install
set -u          # Exit on using unset variable
set -o pipefail # Exit on pipe error

cecho cyanb "Starting ComfyUI nodes installation ..."

if [ -z "$COMFYUI_PATH" ]; then
    cecho red "COMFYUI_PATH must be set to continue. Exiting..."
    exit 1
fi

if [ ! -d "$COMFYUI_PATH" ]; then
    cecho red "Can't find the ComfyUI directory at $COMFYUI_PATH! Exiting..."
    exit 1
fi

if ! command -v comfy &> /dev/null; then
    cecho red "The 'comfy' command is not available! Exiting..."
    exit 1
fi

if [ ! -f "/root/comfy.nodes" ]; then
    cecho red "Can't find the comfy.nodes file! Exiting..."
    exit 1
fi

source /root/comfy.nodes

cecho green "Imported list with ${#COMFY_NODES[@]} nodes, starting installation ..."

for repo in "${COMFY_NODES[@]}"; do
    cecho orange "$repo ..."
    comfy node install "$repo"
done

cecho green "::::: Finished installing the nodes :::::"