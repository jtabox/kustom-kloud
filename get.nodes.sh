#!/bin/bash
# This is run manually after the initial provisioning and downloads the rest of the ComyUI nodes

    # "https://github.com/Gourieff/comfyui-reactor-node"
    # "https://github.com/Acly/comfyui-inpaint-nodes"
    # "https://github.com/space-nuko/ComfyUI-OpenPose-Editor"
    # "https://github.com/kijai/ComfyUI-SUPIR"
    # "https://github.com/space-nuko/nui-suite"
    # "https://github.com/adieyal/comfyui-dynamicprompts"
    # "https://github.com/mcmonkeyprojects/sd-dynamic-thresholding"
    # "https://github.com/WASasquatch/was-node-suite-comfyui"
    # "https://github.com/Fannovel16/comfyui_controlnet_aux"
    # "https://github.com/huchenlei/ComfyUI_densediffusion"
    # "https://github.com/cubiq/ComfyUI_InstantID"
    # "https://github.com/heshengtao/comfyui_LLM_party"
    # "https://github.com/huchenlei/ComfyUI_omost"
    # "https://github.com/ssitu/ComfyUI_UltimateSDUpscale"
    # "https://github.com/talesofai/comfyui-browser"
    # "https://github.com/11cafe/comfyui-workspace-manager"
    # "https://github.com/hayden-fr/ComfyUI-Model-Manager"
    # "https://github.com/city96/ComfyUI-GGUF"
    # "https://github.com/yolain/ComfyUI-Easy-Use"
    # "https://github.com/ltdrdata/ComfyUI-Inspire-Pack"
    # "https://github.com/kijai/ComfyUI-KJNodes"
    # "https://github.com/rgthree/rgthree-comfy"
    # "https://github.com/lks-ai/anynode"
    # "https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes"
    # "https://github.com/cubiq/ComfyUI_essentials"
    # "https://github.com/crystian/ComfyUI-Crystools"
    # "https://github.com/pythongosssss/ComfyUI-Custom-Scripts"
    # "https://github.com/ltdrdata/ComfyUI-Impact-Pack"

# AUTO_UPDATE=true
# COMFYUI_VENV /opt/environments/python/comfyui
# COMFYUI_VENV_PIP /opt/environments/python/comfyui/bin/pip
# COMFYUI_VENV_PYTHON /opt/environments/python/comfyui/bin/python
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
