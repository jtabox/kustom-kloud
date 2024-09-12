#!/bin/bash
# This is run manually after the initial provisioning and downloads/installs the ComyUI nodes below
# It uses https://github.com/ltdrdata/ComfyUI-Manager/blob/main/docs/en/cm-cli.md for complete install

NODES=(
    "https://github.com/11cafe/comfyui-workspace-manager"
    "https://github.com/Acly/comfyui-inpaint-nodes"
    "https://github.com/Fannovel16/comfyui_controlnet_aux"
    "https://github.com/Gourieff/comfyui-reactor-node"
    "https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes"
    "https://github.com/WASasquatch/was-node-suite-comfyui"
    "https://github.com/adieyal/comfyui-dynamicprompts"
    "https://github.com/city96/ComfyUI-GGUF"
    "https://github.com/crystian/ComfyUI-Crystools"
    "https://github.com/cubiq/ComfyUI_InstantID"
    "https://github.com/cubiq/ComfyUI_essentials"
    "https://github.com/hayden-fr/ComfyUI-Model-Manager"
    "https://github.com/heshengtao/comfyui_LLM_party"
    "https://github.com/huchenlei/ComfyUI_densediffusion"
    "https://github.com/huchenlei/ComfyUI_omost"
    "https://github.com/kijai/ComfyUI-KJNodes"
    "https://github.com/kijai/ComfyUI-SUPIR"
    "https://github.com/lks-ai/anynode"
    "https://github.com/ltdrdata/ComfyUI-Impact-Pack"
    "https://github.com/ltdrdata/ComfyUI-Inspire-Pack"
    "https://github.com/mcmonkeyprojects/sd-dynamic-thresholding"
    "https://github.com/pythongosssss/ComfyUI-Custom-Scripts"
    "https://github.com/rgthree/rgthree-comfy"
    "https://github.com/space-nuko/ComfyUI-OpenPose-Editor"
    "https://github.com/space-nuko/nui-suite"
    "https://github.com/ssitu/ComfyUI_UltimateSDUpscale"
    "https://github.com/talesofai/comfyui-browser"
    "https://github.com/yolain/ComfyUI-Easy-Use"
    "https://github.com/giriss/comfy-image-saver"
)

# comfyui venv
source /opt/ai-dock/bin/venv-set.sh comfyui

# COMFYUI_VENV /opt/environments/python/comfyui
# COMFYUI_VENV_PIP /opt/environments/python/comfyui/bin/pip
# COMFYUI_VENV_PYTHON /opt/environments/python/comfyui/bin/python

# python cm-cli.py install node_dir1 node_dir2 ...

COMFYUI_PATH="/opt/ComfyUI"
install_string=""
for repo in "${NODES[@]}"; do
    install_string="${repo##*/} ${install_string}"
done

$COMFYUI_VENV_PYTHON "${COMFYUI_PATH}/custom_nodes/ComfyUI-Manager/cm-cli.py" install ${install_string}

