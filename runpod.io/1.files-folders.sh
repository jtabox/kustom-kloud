#!/bin/bash
# A series of scripts that install packages, ComfyUI, configure and download files.
# 1: Files and folders - root version (no sudo) for runpod.io

set -e          # Exit on error
set -u          # Exit on using unset variable
set -o pipefail # Exit on pipe error

# Shush
touch /root/.hushlogin

# Fetch some files
curl -L -o /root/.bash_aliases https://raw.githubusercontent.com/jtabox/kustom-kloud/main/runpod.io/root.bash_aliases.sh
wget https://raw.githubusercontent.com/jtabox/kustom-kloud/main/common/nano-conf.tgz && \
    tar -xzf nano-conf.tgz -C /root/ && \
    rm nano-conf.tgz && \
    chown -R root:root /root/.nanorc /root/.nano
