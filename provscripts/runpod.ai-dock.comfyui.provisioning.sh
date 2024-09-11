#!/bin/bash
################################################################################################################
# __HIGHLY PERSONALIZED__ provisioning script for ComfyUI AI-Dock containers at runpod.io
# Declared by the environment variable PROVISIONING_SCRIPT, downloaded and run during container init
# https://raw.githubusercontent.com/jtabox/kustom-kloud/main/provscripts/runpod.ai-dock.comfyui.provisioning.sh
#
# Script tasks:
# - apt update + install utils (mc ranger nano curl wget git unzip jq yq gpg aria2 eza)
# - Download customized .bash_aliases with helper funcs
# - Create the folder structure for syncthing and rclone downloads
# - Write the rclone config file and download models
#
# All credit goes to AI-Dock for their great container images that I'm using: https://github.com/ai-dock
################################################################################################################

# apt update + install packages (eza is special and wants its own attention)
printf "\n:::::: Kustom Kloud Provisioner ::: Installing utils\n"
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt-get update && sudo apt-get install -y --no-install-recommends mc ranger highlight jq aria2 eza


# .bash_aliases (both root and comfyui user)
printf "\n:::::: Kustom Kloud Provisioner ::: Downloading .bash_aliases\n"
sudo wget -q -O /root/.bash_aliases https://raw.githubusercontent.com/jtabox/kustom-kloud/main/provscripts/kustom.bash_aliases.sh
wget -q -O ~/.bash_aliases https://raw.githubusercontent.com/jtabox/kustom-kloud/main/provscripts/kustom.bash_aliases.sh
wget -q -O ~/download.helper.sh https://raw.githubusercontent.com/jtabox/kustom-kloud/main/provscripts/download.helper.sh && chmod +x ~/download.helper.sh

source ~/.bash_aliases

# rclone config
printf "\n:::::: Kustom Kloud Provisioner ::: Writing rclone config\n"
cat <<EOF > ~/temp.rclone.conf
[ofvn]
type = sftp
host = ${RUNPOD_SECRET_HETZ_USER}-sub2.your-storagebox.de
user = ${RUNPOD_SECRET_HETZ_USER}-sub2
port = 23
pass = ${RUNPOD_SECRET_HETZ_PASSWD_RO}
shell_type = unix
md5sum_command = md5 -r
sha1sum_command = sha1 -r
EOF
# there should already exist this: RCLONE_CONFIG=/etc/rclone/rclone.conf
sudo mv ~/temp.rclone.conf "$RCLONE_CONFIG" && sudo chown root:root "$RCLONE_CONFIG"

# can also write a simple text file with the login info for the web portal, for easy access
cat <<EOF > ~/login_info.txt
Hi from the provisioner. I will soon dissolve into the void, but here's some info for you:
User:         $USER_NAME
Password:     $USER_PASSWORD
Web User:     $WEB_USER
Web Password: $WEB_PASSWORD
Web Token:    $WEB_TOKEN
EOF

# download models
# rclone_models=(
#     "/sdmodels/Checkpoints/Flux/flux1-dev-fp8.safetensors"
#     "/sdmodels/Checkpoints/Flux/FluxBananadiffusion_v01NF4.safetensors"
#     "/sdmodels/CLIP/t5xxl_fp8_e4m3fn.safetensors"
#     "/sdmodels/CLIP/ViT-L-14-BEST-smooth-GmP-TE-only-HF-format.safetensors"
#     "/sdmodels/Lora/Flux/AndroFlux-v26.safetensors"
#     "/sdmodels/VAE/flux-ae.safetensors"
# )
# for model in "${rclone_models[@]}"; do
#     rclone_download "ckpt" "$model"
# done

# will do it manually for now, need to source the mappings and the function
printf "\n:::::: Kustom Kloud Provisioner ::: Downloading basic models\n"

rclone_download "ckpt" "sdmodels/Checkpoints/Flux/flux1-dev-fp8.safetensors"
rclone_download "ckpt" "sdmodels/Checkpoints/Flux/FluxBananadiffusion_v01NF4.safetensors"
rclone_download "clip" "sdmodels/CLIP/t5xxl_fp8_e4m3fn.safetensors"
rclone_download "clip" "sdmodels/CLIP/ViT-L-14-BEST-smooth-GmP-TE-only-HF-format.safetensors"
rclone_download "lora" "sdmodels/Lora/Flux/AndroFlux-v26.safetensors"
rclone_download "vae" "sdmodels/VAE/flux-ae.safetensors"

# this is from the original script, to download nodes
source /opt/ai-dock/etc/environment.sh
source /opt/ai-dock/bin/venv-set.sh comfyui

NODES=(
    "https://github.com/ltdrdata/ComfyUI-Manager"
    "https://github.com/Acly/comfyui-inpaint-nodes"
    "https://github.com/kijai/ComfyUI-KJNodes"
    "https://github.com/ltdrdata/ComfyUI-Manager"
    "https://github.com/space-nuko/ComfyUI-OpenPose-Editor"
    "https://github.com/Gourieff/comfyui-reactor-node"
    "https://github.com/kijai/ComfyUI-SUPIR"
    "https://github.com/space-nuko/nui-suite"
    "https://github.com/adieyal/comfyui-dynamicprompts"
    "https://github.com/rgthree/rgthree-comfy"
    "https://github.com/mcmonkeyprojects/sd-dynamic-thresholding"
    "https://github.com/WASasquatch/was-node-suite-comfyui"
    "https://github.com/lks-ai/anynode"
    "https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes"
    "https://github.com/Fannovel16/comfyui_controlnet_aux"
    "https://github.com/huchenlei/ComfyUI_densediffusion"
    "https://github.com/cubiq/ComfyUI_essentials"
    "https://github.com/cubiq/ComfyUI_InstantID"
    "https://github.com/heshengtao/comfyui_LLM_party"
    "https://github.com/huchenlei/ComfyUI_omost"
    "https://github.com/ssitu/ComfyUI_UltimateSDUpscale"
    "https://github.com/crystian/ComfyUI-Crystools"
    "https://github.com/pythongosssss/ComfyUI-Custom-Scripts"
    "https://github.com/yolain/ComfyUI-Easy-Use"
    "https://github.com/city96/ComfyUI-GGUF"
    "https://github.com/ltdrdata/ComfyUI-Impact-Pack"
    "https://github.com/ltdrdata/ComfyUI-Inspire-Pack"
)
# "https://github.com/melMass/comfy_mtb"

# AUTO_UPDATE=true
# COMFYUI_VENV_PIP=/opt/environments/python/comfyui/bin/pip
for repo in "${NODES[@]}"; do
    dir="${repo##*/}"
    path="/opt/ComfyUI/custom_nodes/${dir}"
    requirements="${path}/requirements.txt"
    if [[ -d $path ]]; then
        if [[ ${AUTO_UPDATE,,} != "false" ]]; then
            printf "Updating node: %s...\n" "${repo}"
            ( cd "$path" && git pull )
            if [[ -e $requirements ]]; then
               "$COMFYUI_VENV_PIP" install --no-cache-dir -r "$requirements"
            fi
        fi
    else
        printf "Downloading node: %s...\n" "${repo}"
        git clone "${repo}" "${path}" --recursive
        if [[ -e $requirements ]]; then
            "$COMFYUI_VENV_PIP" install --no-cache-dir -r "$requirements"
        fi
    fi
done
