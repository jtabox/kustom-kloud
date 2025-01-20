#!/bin/bash
# shellcheck disable=SC1091
# A series of scripts that install packages, ComfyUI, configure and download files.
# 1: Files and folders - root version (no sudo) for runpod.io

set -e          # Exit on error
set -u          # Exit on using unset variable
set -o pipefail # Exit on pipe error

echo "::::: Starting files and folders setup :::::"
# Shush
touch /root/.hushlogin

# Fetch some files
cd /root || exit 1

wget -qO .bash_aliases https://raw.githubusercontent.com/jtabox/kustom-kloud/main/runpod.io/root.bash_aliases.sh && \
    chown root:root .bash_aliases && \
    source .bash_aliases

wget -q https://raw.githubusercontent.com/jtabox/kustom-kloud/main/common/configs/nano-conf.tgz && \
    tar -xzf nano-conf.tgz -C /root/ && \
    rm nano-conf.tgz && \
    chown -R root:root /root/.nanorc /root/.nano

wget -q https://raw.githubusercontent.com/jtabox/kustom-kloud/main/common/configs/.screenrc && \
    chown root:root .screenrc

wget -q https://raw.githubusercontent.com/jtabox/kustom-kloud/main/common/scripts/comfy.nodes && \
    chown root:root comfy.nodes

wget -q https://raw.githubusercontent.com/jtabox/kustom-kloud/main/common/scripts/comfy.models && \
    chown root:root comfy.models

cecho green "::::: Finished setting up files and folders :::::"