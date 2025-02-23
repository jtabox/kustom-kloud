# ComfyUI Models lists file - passed to download-models-from-list.sh
# shellcheck disable=all

COMFY_MODELS_CKPTS=(
    "https://huggingface.co/Comfy-Org/flux1-dev/resolve/main/flux1-dev-fp8.safetensors"
    "https://huggingface.co/city96/FLUX.1-dev-gguf/resolve/main/flux1-dev-Q8_0.gguf"
    "https://huggingface.co/city96/FLUX.1-dev-gguf/resolve/main/flux1-dev-Q6_K.gguf"
    "https://civitai.com/api/download/models/963454?type=Model&format=GGUF&size=pruned&fp=fp8"
    "https://civitai.com/api/download/models/990314?type=Model&format=SafeTensor&size=pruned&fp=fp8"
)

COMFY_MODELS_LORAS=(
    "https://civitai.com/api/download/models/961155?type=Model&format=SafeTensor"
    "https://civitai.com/api/download/models/840129?type=Model&format=SafeTensor"
    "https://civitai.com/api/download/models/1056339?type=Model&format=SafeTensor"
    "https://civitai.com/api/download/models/985202?type=Model&format=SafeTensor"
    "https://civitai.com/api/download/models/1066361?type=Model&format=SafeTensor"
    "https://civitai.com/api/download/models/1058927?type=Model&format=SafeTensor"
    "https://civitai.com/api/download/models/805890?type=Model&format=SafeTensor"
)

COMFY_MODELS_CLIP=(
    "https://huggingface.co/zer0int/CLIP-GmP-ViT-L-14/resolve/main/ViT-L-14-BEST-smooth-GmP-TE-only-HF-format.safetensors"
    "https://huggingface.co/zer0int/CLIP-GmP-ViT-L-14/resolve/main/ViT-L-14-TEXT-detail-improved-hiT-GmP-TE-only-HF.safetensors"
    "https://huggingface.co/zer0int/CLIP-GmP-ViT-L-14/resolve/main/ViT-L-14-GmP-ft-TE-only-HF-format.safetensors"
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors"
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors"
    "https://huggingface.co/city96/t5-v1_1-xxl-encoder-gguf/resolve/main/t5-v1_1-xxl-encoder-Q8_0.gguf"
    "https://huggingface.co/city96/t5-v1_1-xxl-encoder-gguf/resolve/main/t5-v1_1-xxl-encoder-Q6_K.gguf"
)

COMFY_MODELS_OTHER=(
    "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/ae.safetensors"
    "https://huggingface.co/Kijai/flux-fp8/resolve/main/flux1-dev-fp8.safetensors"
)
