#!/bin/bash
# A series of scripts that install packages, ComfyUI, configure and download files.
# 4: ComfyUI models installation - root version (no sudo) for runpod.io


# set -e          # Exit on error - we want the script to continue if a node fails to install
set -u          # Exit on using unset variable
set -o pipefail # Exit on pipe error

cecho cyanb "Starting ComfyUI models installation ..."

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

source /root/comfy.models

len_ckpts=${#COMFY_MODELS_CKPTS[@]}
len_loras=${#COMFY_MODELS_LORAS[@]}
len_clip=${#COMFY_MODELS_CLIP[@]}
len_other=${#COMFY_MODELS_OTHER[@]}

cecho green "Imported list with:"
cecho green "${len_ckpts} checkpoints"
cecho green "${len_loras} loras"
cecho green "${len_clip} text encoders"
cecho green "${len_other} other models"

cecho green "Fetching checkpoints ..."
ckpt_counter=1
for file_url in "${COMFY_MODELS_CKPTS[@]}"; do
    cecho orange "$ckpt_counter / $len_ckpts ..."
    getaimodel "$file_url ckpt"
    ((ckpt_counter++))
done

# also link the files inside the comfyui checkpoints folder to unet folder
ln "$COMFYUI_PATH/models/checkpoints/*" "$COMFYUI_PATH/models/unet"

cecho green "Fetching loras ..."
loras_counter=1
for file_url in "${COMFY_MODELS_LORAS[@]}"; do
    cecho orange "$loras_counter / $len_loras ..."
    getaimodel "$file_url lora"
    ((loras_counter++))
done

cecho green "Fetching text encoders ..."
clip_counter=1
for file_url in "${COMFY_MODELS_CLIP[@]}"; do
    cecho orange "$clip_counter / $len_clip ..."
    getaimodel "$file_url clip"
    ((clip_counter++))
done

cecho green "Fetching other models, move them from $COMFYUI_PATH/models/_inc ..."
other_counter=1
for file_url in "${COMFY_MODELS_OTHER[@]}"; do
    cecho orange "$other_counter / $len_other ..."
    getaimodel "$file_url inc"
    ((other_counter++))
done

cecho green "::::: Finished installing the models :::::"