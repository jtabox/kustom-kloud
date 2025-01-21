#!/bin/bash
# shellcheck disable=SC1091
# A series of scripts that install packages, ComfyUI, configure and download files and start up apps.
# 1: Files and folders - root version (no sudo) for runpod.io
# wget https://raw.githubusercontent.com/jtabox/kustom-kloud/main/runpod.io/1.files-folders.sh && chmod +x 1.files-folders.sh

set -e          # Exit on error
set -u          # Exit on using unset variable
set -o pipefail # Exit on pipe error

echo -e "\n::::: Starting files and folders setup :::::\n\n"
# Shush
touch /root/.hushlogin

# Fetch some files
cd /root || exit 1

get_config() {
    wget -q "https://raw.githubusercontent.com/jtabox/kustom-kloud/main/$1" || exit 1
    filename=$(basename "$1")
    chown root:root "$filename" || exit 1
    #if a second arg is passed ("exec"), make the file executable
    if [ "$2" = "exec" ]; then
        chmod +x "$filename"
    fi
}

wget -qO .bash_aliases https://raw.githubusercontent.com/jtabox/kustom-kloud/main/runpod.io/root.bash_aliases.sh && \
    chown root:root .bash_aliases && \
    source .bash_aliases

wget -q https://raw.githubusercontent.com/jtabox/kustom-kloud/main/common/configs/nano-conf.tgz && \
    tar -xzf nano-conf.tgz -C /root/ && \
    rm nano-conf.tgz && \
    chown -R root:root /root/.nanorc /root/.nano

get_config "common/scripts/comfy.nodes"
get_config "common/scripts/comfy.models"

get_config "common/configs/.screenrc"
get_config "common/configs/comfy.screenrc"
get_config "common/configs/comfy.settings.json"
get_config "common/configs/comfy.templates.json"
get_config "common/configs/mgr.config.ini"

get_config "runpod.io/2.comfy-install.sh" exec
get_config "runpod.io/3.comfy-nodes.sh" exec
get_config "runpod.io/4.comfy-models.sh" exec
get_config "runpod.io/5.init-apps.sh" exec

cecho green "\n\n::::: Finished setting up files and folders :::::"
cecho yellow "::::: Don't forget to 'source .bash_aliases' ! :::::"
cecho yellow "::::: Next: run './2.comfy-install.sh' to install ComfyUI :::::\n"