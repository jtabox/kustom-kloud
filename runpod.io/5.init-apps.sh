#!/bin/bash
# shellcheck disable=SC1091,SC2016
# A series of scripts that install packages, ComfyUI, configure and download files and start up apps.
# 5: Apps start up - root version (no sudo) for runpod.io
# wget https://raw.githubusercontent.com/jtabox/kustom-kloud/main/runpod.io/5.init-apps.sh && chmod +x 5.init-apps.sh

# set -e          # Exit on error
set -u          # Exit on using unset variable
set -o pipefail # Exit on pipe error

cecho cyan "\n::::: Initializing apps  :::::\n\n"

if [ -z "$NGROK_AUTH_TOKEN" ]; then
    cecho red "NGROK_AUTH_TOKEN must be set in order to use ngrok!"
    cecho red 'Skipping configuration, fix the variable and run: "ngrok config add-authtoken $NGROK_AUTH_TOKEN" manually.'
    exit 1
else
    ngrok config add-authtoken "$NGROK_AUTH_TOKEN"
fi

screen -c /root/comfy.screenrc