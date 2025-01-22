#!/bin/bash
# shellcheck disable=SC1091
# A series of scripts that install packages, ComfyUI, configure and download files and start up apps.
# 1: Files and folders - root version (no sudo) for runpod.io
# wget https://raw.githubusercontent.com/jtabox/kustom-kloud/main/runpod.io/1.files-folders.sh && chmod +x 1.files-folders.sh

# Exit on error, unset variable, pipefail
set -euo pipefail

echo -e "\n::::::::::::::::::::::::::::::::::::::::::::\n::::: Starting files and folders setup :::::\n::::::::::::::::::::::::::::::::::::::::::::\n\n"

# Shush
touch /root/.hushlogin

# Fetch some files
cd /root || exit 1

get_cfg_file() {
    echo -e "\nFetching: $1"
    wget -q "https://raw.githubusercontent.com/jtabox/kustom-kloud/main/$1" || exit 1
    filename=$(basename "$1")
    chown root:root "$filename" || exit 1
    #if a second arg is passed, make the file executable
    if [ "$#" -ge 2 ]; then
        chmod +x "$filename"
    fi
}

echo -e "\nFetching: .bash_aliases"
wget -qO .bash_aliases https://raw.githubusercontent.com/jtabox/kustom-kloud/main/runpod.io/root.bash_aliases.sh && \
    chown root:root .bash_aliases && \
    source .bash_aliases

cecho cyan "\nFetching: nano config files"
wget -q https://raw.githubusercontent.com/jtabox/kustom-kloud/main/common/configs/nano-conf.tgz && \
    tar -xzf nano-conf.tgz -C /root/ && \
    rm nano-conf.tgz && \
    chown -R root:root /root/.nanorc /root/.nano

cecho cyan "\nFetching: comfy download lists"
get_cfg_file "common/scripts/comfy.nodes"
get_cfg_file "common/scripts/comfy.models"

cecho cyan "\nFetching: screen and comfy config files"
get_cfg_file "common/configs/.screenrc"
get_cfg_file "common/configs/comfy.screenrc"
get_cfg_file "common/configs/comfy.settings.json"
get_cfg_file "common/configs/comfy.templates.json"
get_cfg_file "common/configs/mgr.config.ini"

cecho cyan "\nFetching: main scripts 2-5"
get_cfg_file "runpod.io/2.comfy-install.sh" exec
get_cfg_file "runpod.io/3.init-apps.sh" exec
get_cfg_file "runpod.io/4.comfy-nodes.sh" exec
get_cfg_file "runpod.io/5.comfy-models.sh" exec

cecho green "\n\n:::::::::::::::::::::::::::::::::::::::::::::::::\n::::: Finished setting up files and folders :::::\n:::::::::::::::::::::::::::::::::::::::::::::::::\n"
cecho yellow "::::: Next steps ::::::::::::::::::::::::::::::::::::::::::"
cecho yellow "::::: - | source .bash_aliases | ::::::::::::::::::::::::::"
cecho yellow "::::: - | ./2.comfy-install.sh | - to install ComfyUI :::::\n:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n"