#!/bin/bash
# shellcheck disable=SC1091
# This script is called from the Dockerfile towards the end of the build process and is responsible for checking/initializing the /workspace storage mount

# Exit on error, pipefail
set -eo pipefail

# overly complicated header printer
print_header() {
    # usage: print_header <'type'> (always) <'main_text'> or <'text_line1'> <'text_line2'> ['text_line3']
    local type="$1"
    shift
    local color_code

    case "$type" in
    "success") color_code="32" ;;
    "warn") color_code="33" ;;
    "error") color_code="31" ;;
    "info") color_code="36" ;;
    *) color_code="36" ;;
    esac

    local term_width
    term_width=$(tput cols)
    local text_count=$#

    # If only one text, use original behavior
    if [ $text_count -eq 1 ]; then
        local text="$1"
        if [ ${#text} -gt "$term_width" ]; then
            echo -e "\n\033[${color_code}m${text}\033[0m\n"
            return
        fi

        local text_line="::::: ${text} :::::"
        local border_line
        border_line=$(printf ':%.0s' $(seq 1 ${#text_line}))

        echo -e "\n\n\033[${color_code}m${border_line}"
        echo -e "${text_line}"
        echo -e "${border_line}\033[0m\n\n"
        return
    fi

    # Multiple text handling (2 or 3 texts)
    local header_text="$1"
    local middle_text="$2"
    local footer_text="$3"

    local middle_line="::::: ${middle_text} :::::"
    local total_length=${#middle_line}
    local border_line
    border_line=$(printf ':%.0s' $(seq 1 "$total_length"))

    local header_line="::::: ${header_text}"
    local header_padding
    header_padding=$(printf ':%.0s' $(seq 1 $((total_length - ${#header_line} - 1))))
    local header_line="${header_line} ${header_padding}"

    echo -e "\n\n\033[${color_code}m${border_line}"
    echo -e "${header_line}"
    echo -e "${middle_line}"

    if [ $text_count -eq 3 ]; then
        local footer_line="::::: ${footer_text}"
        local footer_padding
        footer_padding=$(printf ':%.0s' $(seq 1 $((total_length - ${#footer_line} - 1))))
        local footer_line="${footer_line} ${footer_padding}"
        echo -e "${footer_line}"
    fi

    echo -e "${border_line}\033[0m\n\n"
}

# Check if workspace even exists in the first place
if [ ! -d "/workspace" ]; then
    print_header 'error' 'Fatal error!' 'The /workspace directory can not be found! Is the storage volume mounted?' 'Exiting ...'
    exit 1
fi

if [ -f "/workspace/_INSTALL_COMPLETE" ]; then
    # This is created after the first time a fresh volume is initialized
    print_header 'info' 'The /workspace folder seems already initialized. Will only adjust specific files as needed.'
    FIRST_TIME_INSTALL=0
else
    print_header 'info' 'The /workspace folder has not been initialized. Executing first-time setup.'
    FIRST_TIME_INSTALL=1
fi

# The /root, /usr/local/lib/python3.11 installation and /usr/local/bin (has many python executables) will be storaged in /workspace for permanence.
# They are moved (with any existing contents) if it's the first-time setup, and links are created to the original location.
# Otherwise they are deleted and only links are created.

if [ $FIRST_TIME_INSTALL -eq 1 ]; then
    echo "::::> Moving /root, /usr/local/lib/python3.11 and /usr/local/bin to /workspace"
    mkdir -p /workspace/containerdirs &&
        chmod 755 /workspace/containerdirs
    # /root -> /workspace/containerdirs/root
    mv /root /workspace/containerdirs/root
    # python3.11 -> /workspace/containerdirs/usrlocallib_py311
    mv /usr/local/lib/python3.11 /workspace/containerdirs/usrlocallib_py311
    # usr/local/bin -> /workspace/containerdirs/usrlocalbin
    mv /usr/local/bin /workspace/containerdirs/usrlocalbin
else
    echo "::::> Removing /root, /usr/local/lib/python3.11 and /usr/local/bin"
    rm -rf /root
    rm -rf /usr/local/lib/python3.11
    rm -rf /usr/local/bin
fi

echo "::::> Linking /root, /usr/local/lib/python3.11 and /usr/local/bin to their workspace counterparts"
ln -s /workspace/containerdirs/root /root
ln -s /workspace/containerdirs/usrlocallib_py311 /usr/local/lib/python3.11
ln -s /workspace/containerdirs/usrlocalbin /usr/local/bin

for linked_dir in "/root" "/usr/local/lib/python3.11" "/usr/local/bin"; do
    if [ ! -L "$linked_dir" ]; then
        echo "!! Error !! $linked_dir is not a symbolic link!"
        exit 1
    fi
    if ! (cd "$linked_dir" 2>/dev/null); then
        echo "!! Error !! $linked_dir can't be accessed!"
        exit 1
    fi
done

# Function to fetch files from the repo (though gotta check if i can fetch them from /workspace or while building the image from the repo)
# https://raw.githubusercontent.com/jtabox/kustom-kloud/main/common/configs/comfy-session.screenrc
# https://raw.githubusercontent.com/jtabox/kustom-kloud/main/runpod.io/root.bash_aliases.sh
get_repo_file() {
    local reponame
    reponame="jtabox/kustom-kloud"
    local branchname
    branchname="main"
    # Check how many args, if 2 then use arg2 as folder and filename for the output, otherwise assume the existing filename in current directory
    local outputfile
    if [ "$#" -ge 2 ]; then
        outputfile="$2"
    else
        outputfile="./"$(basename "$1")
    fi
    echo -e "\n::::> Fetching $reponame/$branchname/$1 to $outputfile"
    wget -qO "$outputfile" "https://raw.githubusercontent.com/$reponame/$branchname/$1" &&
        chown root:root "$outputfile" &&
        echo "Done"
}

cd /root

if [ $FIRST_TIME_INSTALL -eq 1 ]; then
    print_header 'info' 'Starting files and folders setup'

    # stfu motd
    touch /root/.hushlogin

    get_repo_file "runpod.io/root.bash_aliases.sh" "/root/.bash_aliases" &&
        source /root/.bash_aliases

    get_repo_file "common/configs/nano-conf.tgz" &&
        tar -xzf nano-conf.tgz -C /root/ &&
        rm /root/nano-conf.tgz &&
        chown -R root:root /root/.nanorc /root/.nano

    get_repo_file "common/scripts/comfy.nodes"
    get_repo_file "common/scripts/comfy.models"
    get_repo_file "common/scripts/extra.models"

    get_repo_file "common/configs/.screenrc"
    get_repo_file "common/configs/comfy-session.screenrc"
    get_repo_file "common/configs/comfy.settings.json"
    get_repo_file "common/configs/comfy.templates.json"
    get_repo_file "common/configs/mgr.config.ini"

    print_header 'success' 'Finished setting up files and folders'

    print_header 'info' 'Installing ComfyUI and Manager'

    cd /workspace

    git clone https://github.com/comfyanonymous/ComfyUI.git &&
        cd /workspace/ComfyUI/custom_nodes &&
        git clone https://github.com/ltdrdata/ComfyUI-Manager.git &&
        cecho green "ComfyUI and Manager cloned successfully"

    # Install comfy
    python -m pip install --upgrade pip
    pip install torch==2.5.1+cu124 torchvision torchaudio xformers --index-url https://download.pytorch.org/whl/cu124
    pip install --no-build-isolation flash-attn
    pip install -r /workspace/ComfyUI/requirements.txt &&
        pip install -r /workspace/ComfyUI/custom_nodes/ComfyUI-Manager/requirements.txt &&
        pip install comfy-cli

    mkdir -p "$COMFYUI_PATH"/user/default/ComfyUI-Manager
    mv /root/comfy.settings.json /root/comfy.templates.json "$COMFYUI_PATH"/user/default
    cp /root/mgr.config.ini "$COMFYUI_PATH"/custom_nodes/ComfyUI-Manager/config.ini
    mv /root/mgr.config.ini "$COMFYUI_PATH"/user/default/ComfyUI-Manager/config.ini

    mkdir -p "/root/.config/comfy-cli"
    cat <<EOF >/root/.config/comfy-cli/config.ini
[DEFAULT]
enable_tracking = False
default_workspace = $COMFYUI_PATH
default_launch_extras =
recent_workspace = $COMFYUI_PATH

EOF

    cecho green "\n\n:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n::::: ComfyUI & Manager installation completed successfully :::::\n:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n\n"

    cecho cyan "\n\n:::::::::::::::::::::::::::::::::::::::::::\n::::: Initializing ngrok & SyncThing  :::::\n:::::::::::::::::::::::::::::::::::::::::::\n\n"

    if [ -z "$NGROK_AUTH_TOKEN" ]; then
        cecho red "NGROK_AUTH_TOKEN must be set in order to write ngrok's configuration!"
        exit 1
    fi

    mkdir -p /root/.config/ngrok

    cat <<EOF >/root/.config/ngrok/ngrok.yml
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

    # Prepare the scp command using $RUNPOD_TCP_PORT_22 and $RUNPOD_PUBLIC_IP
    scp_command="scp -P $RUNPOD_TCP_PORT_22 -i .ssh_key /path/to/config.xml root@$RUNPOD_PUBLIC_IP:/root/config.xml"
    cecho orange "For the next step, send the SyncThing config file manually via the following command:"
    cecho orange "$scp_command"
    cecho orange "Press Enter to continue afterwards. If no file is uploaded, the script will exit."
    read -r

    if [ ! -f "/root/config.xml" ]; then
        cecho red "Can't find the syncthing.config.xml file! Exiting..."
        exit 1
    else
        mkdir -p /root/.local/state/syncthing
        mv /root/config.xml /root/.local/state/syncthing/config.xml
        cecho green "Syncthing configuration file moved successfully"
    fi
    touch /workspace/_INSTALL_COMPLETE
    cecho orange "\n:: To install the initial node collection from file: 'install_multiple_nodes /root/comfy.nodes'"
    cecho orange ":: To install the initial model collection from file: 'download_multiple_models /root/comfy.models'\n"
else
    # All the above are already in /workspace, just source the bash_aliases
    source /root/.bash_aliases
fi

cecho green "\n\n:::::::::::::::::::::::::::::::::::::\n::::: Initialization completed. :::::\n:::::::::::::::::::::::::::::::::::::\n\n"

screen -c /root/comfy-session.screenrc -S comfy
