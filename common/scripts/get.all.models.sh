#!/bin/bash
# This is run manually after the initial provisioning and downloads all the models specified below

# For some reason the target folders don't get created during ini, so I do it here

UNET_MODELS=(
    "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/flux1-dev.safetensors"
)

CLIP_MODELS=(
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors"
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors"
    "https://huggingface.co/zer0int/CLIP-GmP-ViT-L-14/resolve/main/ViT-L-14-BEST-smooth-GmP-TE-only-HF-format.safetensors"
    "https://huggingface.co/zer0int/CLIP-GmP-ViT-L-14/resolve/main/ViT-L-14-TEXT-detail-improved-hiT-GmP-TE-only-HF.safetensors"
)

CKPT_MODELS=(
    "https://huggingface.co/Comfy-Org/flux1-dev/resolve/main/flux1-dev-fp8.safetensors"
    "https://civitai.com/api/download/models/727894?type=Model&format=SafeTensor&size=full&fp=fp8"
)

LORA_MODELS=(
    "https://civitai.com/api/download/models/805890?type=Model&format=SafeTensor"
)

VAE_MODELS=(
    "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/ae.safetensors"
)

SD_STORAGE_DIR="${WORKSPACE}/storage/stable_diffusion/models"

mkdir -p "${SD_STORAGE_DIR}/unet"
mkdir -p "${SD_STORAGE_DIR}/clip"
mkdir -p "${SD_STORAGE_DIR}/ckpt"
mkdir -p "${SD_STORAGE_DIR}/lora"
mkdir -p "${SD_STORAGE_DIR}/vae"

for model in "${UNET_MODELS[@]}"; do
    fetch_url "$model" "${SD_STORAGE_DIR}/unet"
done

for model in "${CLIP_MODELS[@]}"; do
    fetch_url "$model" "${SD_STORAGE_DIR}/clip"
done

for model in "${CKPT_MODELS[@]}"; do
    fetch_url "$model" "${SD_STORAGE_DIR}/ckpt"
done

for model in "${LORA_MODELS[@]}"; do
    fetch_url "$model" "${SD_STORAGE_DIR}/lora"
done

for model in "${VAE_MODELS[@]}"; do
    fetch_url "$model" "${SD_STORAGE_DIR}/vae"
done


cecho green "::::: Finished downloading the models :::::"