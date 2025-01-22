#!/bin/bash
# shellcheck disable=SC1091,SC2016
# A series of scripts that install packages, ComfyUI, configure and download files and start up apps.
# 3: Apps initialization and start up - root version (no sudo) for runpod.io
# wget https://raw.githubusercontent.com/jtabox/kustom-kloud/main/runpod.io/5.init-apps.sh && chmod +x 5.init-apps.sh

# set -e          # Exit on error
set -u          # Exit on using unset variable
set -o pipefail # Exit on pipe error

cecho cyan "\n::::: Initializing ngrok & syncthing  :::::\n\n"

if [ -z "$NGROK_AUTH_TOKEN" ]; then
    cecho red "NGROK_AUTH_TOKEN must be set in order to write ngrok's configuration!"
    exit 1
fi

cat <<EOF > /root/.config/ngrok/ngrok.yml
version: "3"
agent:
  authtoken: $NGROK_AUTH_TOKEN

tunnels:
  comfy:
    proto: http
    addr: 8188
    domain: "civil-known-bluebird.ngrok-free.app"
    oauth:
      provider: "google"
      allow_emails: ["j.tabox@gmail.com"]
  syncthing:
    proto: http
    addr: 8384
    oauth:
      provider: "google"
      allow_emails: ["j.tabox@gmail.com"]
  jupyter:
    proto: http
    addr: 8888
    oauth:
      provider: "google"
      allow_emails: ["j.tabox@gmail.com"]
EOF

cecho green "ngrok configuration written successfully"
cecho orange "For the next step, you need to manually send the SyncThing config file via scp to the root folder before continuing."
cecho orange "Press Enter to continue afterwards. If no file is uploaded, the script will exit."
read -r

if [ ! -f "/root/config.xml" ]; then
    cecho red "Can't find the syncthing.config.xml file! Exiting..."
    exit 1
else
    mkdir -p /root/.config/state/syncthing
    mv /root/config.xml /root/.config/state/syncthing/config.xml
    cecho green "Syncthing configuration file moved successfully"
    cecho orange "Press Enter to start the session..."
    read -r
fi

screen -c /root/comfy.screenrc