# ComfyUI Models lists file - passed to download-models-from-list.sh
# shellcheck disable=all

COMFY_MODELS_CKPTS=(
    # normal fp8 flux1-dev - rename to ckpt
    "https://huggingface.co/Comfy-Org/flux1-dev/resolve/main/flux1-dev-fp8.safetensors"
    # gguf variants
    "https://huggingface.co/city96/FLUX.1-dev-gguf/resolve/main/flux1-dev-Q8_0.gguf"
    "https://huggingface.co/city96/FLUX.1-dev-gguf/resolve/main/flux1-dev-Q6_K.gguf"
    # sapian
    "https://civitai.com/api/download/models/963454?type=Model&format=GGUF&size=pruned&fp=fp8"
    # pulsar
    "https://civitai.com/api/download/models/990314?type=Model&format=SafeTensor&size=pruned&fp=fp8"
    # unet only - rename to unet
    "https://huggingface.co/Kijai/flux-fp8/resolve/main/flux1-dev-fp8.safetensors"
    # scaled flux
    "https://huggingface.co/comfyanonymous/flux_dev_scaled_fp8_test/resolve/main/flux_dev_fp8_scaled_diffusion_model.safetensors"
    # Flux uncensored
    "https://civitai.com/api/download/models/1249447?type=Model&format=SafeTensor&size=full&fp=fp8"
)

COMFY_MODELS_LORAS=(
    # the huge sized ones, rest i'll send with syncthing
    "https://civitai.com/api/download/models/961155?type=Model&format=SafeTensor"
    "https://civitai.com/api/download/models/840129?type=Model&format=SafeTensor"
    "https://civitai.com/api/download/models/1056339?type=Model&format=SafeTensor"
    "https://civitai.com/api/download/models/985202?type=Model&format=SafeTensor"
    "https://civitai.com/api/download/models/1066361?type=Model&format=SafeTensor"
    "https://civitai.com/api/download/models/1058927?type=Model&format=SafeTensor"
    "https://civitai.com/api/download/models/805890?type=Model&format=SafeTensor"
    # lora controlnets
    "https://huggingface.co/black-forest-labs/FLUX.1-Canny-dev-lora/resolve/main/flux1-canny-dev-lora.safetensors"
    "https://huggingface.co/black-forest-labs/FLUX.1-Depth-dev-lora/resolve/main/flux1-depth-dev-lora.safetensors"
)

COMFY_MODELS_CLIP=(
    # better clips
    "https://huggingface.co/zer0int/CLIP-GmP-ViT-L-14/resolve/main/ViT-L-14-BEST-smooth-GmP-TE-only-HF-format.safetensors"
    "https://huggingface.co/zer0int/CLIP-GmP-ViT-L-14/resolve/main/ViT-L-14-TEXT-detail-improved-hiT-GmP-TE-only-HF.safetensors"
    "https://huggingface.co/zer0int/CLIP-GmP-ViT-L-14/resolve/main/ViT-L-14-GmP-ft-TE-only-HF-format.safetensors"
    # normal text encoders
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors"
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors"
    # gguf t5
    "https://huggingface.co/city96/t5-v1_1-xxl-encoder-gguf/resolve/main/t5-v1_1-xxl-encoder-Q8_0.gguf"
    "https://huggingface.co/city96/t5-v1_1-xxl-encoder-gguf/resolve/main/t5-v1_1-xxl-encoder-Q6_K.gguf"
    # scaled t5
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn_scaled.safetensors"
    # CLIP-L & CLIP-G Full FP32
    "https://civitai.com/api/download/models/1172273?type=Model&format=SafeTensor&size=pruned&fp=fp32"
    "https://civitai.com/api/download/models/1176578?type=Model&format=SafeTensor&size=pruned&fp=fp32"
)

COMFY_MODELS_OTHER=(
    # vae
    "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/ae.safetensors"
    # shakker cnet union pro
    "https://huggingface.co/Shakker-Labs/FLUX.1-dev-ControlNet-Union-Pro/resolve/main/diffusion_pytorch_model.safetensors"
    # shakker cnet union pro fp8
    "https://huggingface.co/Kijai/flux-fp8/resolve/main/flux_shakker_labs_union_pro-fp8_e4m3fn.safetensors"
)
