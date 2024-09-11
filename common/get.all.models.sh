#!/bin/bash
# This is run manually after the initial provisioning and downloads all the models specified below

MODELS=(
    "sdmodels/Checkpoints/Flux/flux1-dev-fp8.safetensors"
    "sdmodels/VAE/flux-ae.safetensors"
)
for model in "${MODELS[@]}"; do
    fetch_url "$model"
done

# will do it manually for now, need to source the mappings and the function
# printf "\n:::::: Kustom Kloud Provisioner ::: Downloading basic models\n"

# rclone_download "ckpt" "sdmodels/Checkpoints/Flux/flux1-dev-fp8.safetensors"
# rclone_download "ckpt" "sdmodels/Checkpoints/Flux/FluxBananadiffusion_v01NF4.safetensors"
# rclone_download "clip" "sdmodels/CLIP/t5xxl_fp8_e4m3fn.safetensors"
# rclone_download "clip" "sdmodels/CLIP/ViT-L-14-BEST-smooth-GmP-TE-only-HF-format.safetensors"
# rclone_download "lora" "sdmodels/Lora/Flux/AndroFlux-v26.safetensors"
# rclone_download "vae" "sdmodels/VAE/flux-ae.safetensors"
