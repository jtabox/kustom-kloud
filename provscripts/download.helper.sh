#!/bin/bash

# Helper script that downloads files from various sources. Is sourced by other scripts.

# Mappings
# $WORKSPACE/storage/stable_diffusion/models/ckpt --> /opt/ComfyUI/models/checkpoints
# $WORKSPACE/storage/stable_diffusion/models/clip --> /opt/ComfyUI/models/clip
# $WORKSPACE/storage/stable_diffusion/models/clip_vision --> /opt/ComfyUI/models/clip_vision
# $WORKSPACE/storage/stable_diffusion/models/controlnet --> /opt/ComfyUI/models/controlnet
# $WORKSPACE/storage/stable_diffusion/models/diffusers --> /opt/ComfyUI/models/diffusers
# $WORKSPACE/storage/stable_diffusion/models/embeddings --> /opt/ComfyUI/models/embeddings
# $WORKSPACE/storage/stable_diffusion/models/facedetection --> /opt/ComfyUI/models/facedetection
# $WORKSPACE/storage/stable_diffusion/models/facerestore --> /opt/ComfyUI/models/facerestore_models
# $WORKSPACE/storage/stable_diffusion/models/esrgan --> /opt/ComfyUI/models/upscale_models
# $WORKSPACE/storage/stable_diffusion/models/gligen --> /opt/ComfyUI/models/gligen
# $WORKSPACE/storage/stable_diffusion/models/hypernetworks --> /opt/ComfyUI/models/hypernetworks
# $WORKSPACE/storage/stable_diffusion/models/insightface --> /opt/ComfyUI/models/insightface
# $WORKSPACE/storage/stable_diffusion/models/ipadapter --> /opt/ComfyUI/models/ipadapter
# $WORKSPACE/storage/stable_diffusion/models/lora --> /opt/ComfyUI/models/loras
# $WORKSPACE/storage/stable_diffusion/models/reactor --> /opt/ComfyUI/models/reactor
# $WORKSPACE/storage/stable_diffusion/models/style_models --> /opt/ComfyUI/models/style_models
# $WORKSPACE/storage/stable_diffusion/models/ultralytics --> /opt/ComfyUI/models/ultralytics
# $WORKSPACE/storage/stable_diffusion/models/unet --> /opt/ComfyUI/models/unet
# $WORKSPACE/storage/stable_diffusion/models/vae --> /opt/ComfyUI/models/vae
# $WORKSPACE/storage/stable_diffusion/models/vae_approx --> /opt/ComfyUI/models/upscale_models


# rclone_download <target_dir> <file>
function rclone_download {
    # example target_dir: "ckpt", "clip"
    # example files:
    # "/sdmodels/Checkpoints/Flux/FluxBananadiffusion_v01NF4.safetensors"
    # "/sdmodels/CLIP/t5xxl_fp8_e4m3fn.safetensors"

    local target_dir=$1
    local file=$2
    local source_file=$RCLONE_REMOTE:$file
    local target_file
    target_file=$WORKSPACE/storage/stable_diffusion/models/$target_dir/$(basename "$file")

    cecho yellow "Downloading and symlinking $source_file to $target_file"
    rclone copy "$source_file" "$target_file"

    # Symlink
    local storage_map_key="stable_diffusion/models/$target_dir"
    ln -s "$target_file" "${storage_map[$storage_map_key]}"

    cecho green "Done."

    return
}

# other_download <url> <target dir>
function other_download {
    # use tokens by default (RUNPOD_SECRET_HF_TOKEN, RUNPOD_SECRET_CIVITAI_TOKEN)
    if [[ $1 =~ ^https://([a-zA-Z0-9_-]+\.)?huggingface\.co(/|$|\?) ]]; then
        auth_token="$RUNPOD_SECRET_HF_TOKEN"
    elif [[ $1 =~ ^https://([a-zA-Z0-9_-]+\.)?civitai\.com(/|$|\?) ]]; then
        auth_token="$RUNPOD_SECRET_CIVITAI_TOKEN"
    fi

    wget --header="Authorization: Bearer $auth_token" -qnc --content-disposition --show-progress -e dotbytes=4M -P "$2" "$1"

    return
}