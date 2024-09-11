#!/bin/bash
################################################################################################################
# __HIGHLY PERSONALIZED__ provisioning script for my ComfyUI AI-Dock containers at runpod.io
# https://raw.githubusercontent.com/jtabox/kustom-kloud/main/runpod.io/ai-dock.comfyui.provisioning.sh
# Base image: https://github.com/ai-dock/comfyui
################################################################################################################

# some package installs (eza is special and wants its own attention)
printf "\n:::::: Kustom Kloud Provisioner ::: Installing helper utils ::::::\n"
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt-get update && sudo apt-get install -y --no-install-recommends mc ranger highlight jq aria2 eza

# customized .bash_aliases (both root and comfyui user) with helper functions and other helpful scripts
printf "\n:::::: Kustom Kloud Provisioner ::: Downloading helpful scripts ::::::\n"
sudo wget -q -O /root/.bash_aliases https://raw.githubusercontent.com/jtabox/kustom-kloud/main/common/kustom.bash_aliases.sh
sudo wget -q -O /root/download.helper.sh https://raw.githubusercontent.com/jtabox/kustom-kloud/main/common/download.helper.sh && sudo chmod +x ~/download.helper.sh
wget -q -O ~/.bash_aliases https://raw.githubusercontent.com/jtabox/kustom-kloud/main/common/kustom.bash_aliases.sh
wget -q -O ~/download.helper.sh https://raw.githubusercontent.com/jtabox/kustom-kloud/main/common/download.helper.sh && chmod +x ~/download.helper.sh

source ~/.bash_aliases

# rclone config
cecho cyan ":::::: Kustom Kloud Provisioner ::: Writing rclone config ::::::"
cat <<EOF > ~/temp.rclone.conf
[ofvn]
type = sftp
host = ${HETZ_USER}-sub2.your-storagebox.de
user = ${HETZ_USER}-sub2
port = 23
pass = ${HETZ_PWD_RO}
shell_type = unix
md5sum_command = md5 -r
sha1sum_command = sha1 -r
EOF
# this env var should already exist: RCLONE_CONFIG=/etc/rclone/rclone.conf
sudo mv ~/temp.rclone.conf "$RCLONE_CONFIG" && sudo chown root:root "$RCLONE_CONFIG"

# can also write a simple text file with the login info for the web portal, for easy access
cat <<EOF > ~/login_info.txt
Hi from the provisioner.
I'm almost done with my purpose and will soon dissolve into the void, but here's some info for you:

- System --------------------------------------------
User:         $USER_NAME
Password:     $USER_PASSWORD

- Web service ---------------------------------------
Web User:     $WEB_USER
Web Password: $WEB_PASSWORD

Web Token:    $WEB_TOKEN

EOF

# the below are from the original provisioning script
# https://github.com/ai-dock/comfyui/blob/main/config/provisioning/default.sh

# comfyui venv
source /opt/ai-dock/etc/environment.sh
source /opt/ai-dock/bin/venv-set.sh comfyui

# COMFYUI_VENV /opt/environments/python/comfyui
# COMFYUI_VENV_PIP /opt/environments/python/comfyui/bin/pip
# COMFYUI_VENV_PYTHON /opt/environments/python/comfyui/bin/python

# will only install ComfyUI-Manager node during provisioning, the rest together with some models manually later
repo="https://github.com/ltdrdata/ComfyUI-Manager"
dir="${repo##*/}"
path="/opt/ComfyUI/custom_nodes/${dir}"
requirements="${path}/requirements.txt"

if [[ ! -d $path ]]; then
    cecho yellow "Downloading and installing ComfyUI-Manager node..."
    git clone "${repo}" "${path}" --recursive
    if [[ -e $requirements ]]; then
        "$COMFYUI_VENV_PIP" install --no-cache-dir -r "$requirements"
    fi
fi

# done
cecho cyan ":::::: Kustom Kloud Provisioner ::: Provisioning script complete"
