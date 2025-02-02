#!/bin/bash
# shellcheck disable=SC1091

# Megascript that prepares a pod for ComfyUI, with relevant installs and configs.
# Checks for /workspace to decide if this a first time install, or a new instance with previous data.
# Runs as root, no sudo required.

# Download manually at first run:
# cd / && wget -qO /root/mega_startup.sh https://raw.githubusercontent.com/jtabox/kustom-kloud/megascript-v2/runpod.io/mega_startup.sh && chmod +x /root/mega_startup.sh && /root/mega_startup.sh

# Exit on error, pipefail and set up cleanup trap
set -eo pipefail

# Cleanup function
cleanup() {
    local exit_code=$?
    echo -e "\nCleaning up..."
    # Stop any background processes
    jobs -p | xargs -r kill
    # Remove any temporary files
    rm -f /tmp/mega_startup_*
    exit $exit_code
}

# Set up trap for cleanup
trap cleanup EXIT INT TERM

# Function to handle errors
error_handler() {
    local line_no=$1
    local error_code=$2
    echo -e "\nError occurred in script at line: ${line_no}"
    echo "Error code: ${error_code}"
    exit "${error_code}"
}
trap 'error_handler ${LINENO} $?' ERR

# Function to check command success
check_command() {
    if ! "$@"; then
        echo -e "\nError: Command failed: $*"
        return 1
    fi
}

# Progress spinner function
spinner() {
    local pid=$1
    local delay=0.1
    # shellcheck disable=SC1003
    local spinstr='|/-\'
    while ps -p "$pid" > /dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Function to check prerequisites
check_prerequisites() {
    echo -e "\nChecking prerequisites..."

    # Check for /workspace directory
    if [ ! -d "/workspace" ]; then
        echo -e "\nFatal error:\nA /workspace directory can't be found, make sure a volume is mounted there. Exiting ...\n"
        exit 1
    fi

    # Check for required commands
    local required_commands=("wget" "curl" "git" "python" "pip")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo -e "\nFatal error: Required command '$cmd' not found. Please install it first."
            exit 1
        fi
    done

    echo "All prerequisites met."
}

# Function to install system packages
install_system_packages() {
    echo -e "\n\n:::::::::::::::::::::::::::::::::::::\n::::: Starting package installs :::::\n:::::::::::::::::::::::::::::::::::::\n\n"

    # Create temporary files for package lists
    local basic_packages="/tmp/mega_startup_basic_packages"
    local dev_packages="/tmp/mega_startup_dev_packages"

    # Basic packages list
    cat > "$basic_packages" << 'EOF'
aria2
btop
cifs-utils
dos2unix
duf
espeak-ng
ffmpeg
git-lfs
jq
lsof
mc
ncdu
nano
ranger
rsync
screen
unzip
zip
EOF

    # Dev packages list
    cat > "$dev_packages" << 'EOF'
autoconf
automake
cmake
gfortran
libatlas-base-dev
libhdf5-serial-dev
libssl-dev
build-essential
python3-dev
libffi-dev
libncurses5-dev
libbz2-dev
liblzma-dev
libreadline-dev
libsqlite3-dev
zlib1g-dev
EOF

    # Update and upgrade in parallel
    echo ":: Updating package lists..."
    apt-get update -y &
    local update_pid=$!
    spinner $update_pid
    wait $update_pid

    echo ":: Upgrading packages..."
    apt-get upgrade -y &
    local upgrade_pid=$!
    spinner $upgrade_pid
    wait $upgrade_pid

    # Install packages in parallel groups
    echo ":: Installing basic packages..."
    check_command xargs -a "$basic_packages" apt-get install -y --no-install-recommends &
    local basic_pid=$!
    spinner $basic_pid
    wait $basic_pid

    echo ":: Installing dev packages..."
    check_command xargs -a "$dev_packages" apt-get install -y --no-install-recommends &
    local dev_pid=$!
    spinner $dev_pid
    wait $dev_pid

    # Cleanup temporary files
    rm -f "$basic_packages" "$dev_packages"
}

# Function to install third-party repositories and packages
install_third_party_repos() {
    echo -e "\n:: Installing extra packages from other repos"

    # Create keyrings directory with proper permissions
    mkdir -p /etc/apt/keyrings
    chmod 755 /etc/apt/keyrings

    # Function to safely add a repository
    add_repo() {
        local name=$1
        local key_url=$2
        local key_path=$3
        local repo_entry=$4
        local list_path="/etc/apt/sources.list.d/${name}.list"

        echo "Adding repository: ${name}"
        if ! wget -qO- --no-check-certificate "$key_url" | gpg --dearmor -o "$key_path"; then
            echo "Failed to download or process key for ${name}"
            return 1
        fi
        chmod 644 "$key_path"
        echo "$repo_entry" | tee "$list_path" > /dev/null
        chmod 644 "$list_path"
    }

    # Add repositories
    add_repo "gierens" \
        "https://raw.githubusercontent.com/eza-community/eza/main/deb.asc" \
        "/etc/apt/keyrings/gierens.gpg" \
        "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main"

    add_repo "ngrok" \
        "https://ngrok-agent.s3.amazonaws.com/ngrok.asc" \
        "/etc/apt/trusted.gpg.d/ngrok.asc" \
        "deb https://ngrok-agent.s3.amazonaws.com buster main"

    add_repo "syncthing" \
        "https://syncthing.net/release-key.gpg" \
        "/etc/apt/keyrings/syncthing-archive-keyring.gpg" \
        "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable"

    add_repo "openziti" \
        "https://get.openziti.io/tun/package-repos.gpg" \
        "/usr/share/keyrings/openziti.gpg" \
        "deb [signed-by=/usr/share/keyrings/openziti.gpg] https://packages.openziti.org/zitipax-openziti-deb-stable debian main"

    # Update package lists and install packages
    apt-get update
    check_command apt-get install -y --no-install-recommends \
        eza \
        ngrok \
        syncthing \
        zrok
}

# Function to install direct download packages
install_direct_downloads() {
    echo -e "\n:: Installing direct downloads"
    local temp_dir="/tmp/mega_startup_downloads"
    mkdir -p "$temp_dir"
    cd "$temp_dir" || return 1

    # Function to download and install a deb package
    install_deb() {
        local name=$1
        local url=$2
        local file="${name}.deb"

        echo "Installing ${name}..."
        if wget --no-check-certificate -qO "$file" "$url" && \
           dpkg -i "$file"; then
            echo "${name} installed successfully"
        else
            echo "Failed to install ${name}"
            return 1
        fi
    }

    # Install packages
    install_deb "bat" "https://github.com/sharkdp/bat/releases/download/v0.25.0/bat_0.25.0_amd64.deb"
    install_deb "ripgrep" "https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep_14.1.1-1_amd64.deb"

    echo "Installing ctop..."
    if curl -sSLo /usr/local/bin/ctop https://github.com/LordOverlord/ctop/releases/download/v0.1.8/ctop-linux-amd64; then
        chmod +x /usr/local/bin/ctop
        echo "ctop installed successfully"
    else
        echo "Failed to install ctop"
        return 1
    fi

    echo "Installing uv..."
    if wget -qO- https://astral.sh/uv/install.sh | sh; then
        echo "uv installed successfully"
    else
        echo "Failed to install uv"
        return 1
    fi

    # Cleanup
    cd - > /dev/null
    rm -rf "$temp_dir"
}

# Enhanced repository file fetching function
get_repo_file() {
    local url_base="https://raw.githubusercontent.com/jtabox/kustom-kloud/megascript-v2"
    local file_path=$1
    local make_executable=${2:-false}
    local filename
    filename=$(basename "$file_path")

    echo -e "\n:: Fetching: $file_path"

    # Try up to 3 times to download the file
    local max_attempts=3
    local attempt=1
    while [ $attempt -le $max_attempts ]; do
        if wget -q --no-check-certificate "${url_base}/${file_path}" -O "$filename"; then
            # Verify file was downloaded and is not empty
            if [ -s "$filename" ]; then
                chown root:root "$filename"
                if [ "$make_executable" = true ]; then
                    chmod +x "$filename"
                else
                    chmod 644 "$filename"
                fi
                echo "Successfully downloaded: $filename"
                return 0
            fi
        fi

        echo "Attempt $attempt of $max_attempts failed. Retrying..."
        rm -f "$filename"
        attempt=$((attempt + 1))
        sleep 1
    done

    echo "Failed to download $filename after $max_attempts attempts"
    return 1
}

# Function to set up initial files and folders
setup_initial_files() {
    echo -e "\n\n::::::::::::::::::::::::::::::::::::::::::::\n::::: Starting files and folders setup :::::\n::::::::::::::::::::::::::::::::::::::::::::\n\n"

    # Create .hushlogin to suppress login messages
    touch /root/.hushlogin

    # Change to root directory
    cd /root || {
        echo "Failed to change to /root directory"
        return 1
    }

    # Download and set up bash aliases
    echo -e "\n:: Setting up bash aliases"
    if wget -q --no-check-certificate -O .bash_aliases \
        "https://raw.githubusercontent.com/jtabox/kustom-kloud/megascript-v2/runpod.io/root.bash_aliases.sh"; then
        chown root:root .bash_aliases
        chmod 644 .bash_aliases
        # shellcheck source=/dev/null
        source .bash_aliases
        echo "Bash aliases configured successfully"
    else
        echo "Failed to download bash aliases"
        return 1
    fi

    # Download and extract nano config
    cecho cyan "\n:: Setting up nano configuration"
    if wget -q --no-check-certificate \
        "https://raw.githubusercontent.com/jtabox/kustom-kloud/megascript-v2/common/configs/nano-conf.tgz" && \
        tar -xzf nano-conf.tgz -C /root/ && \
        rm nano-conf.tgz; then
        chown -R root:root /root/.nanorc /root/.nano
        chmod 644 /root/.nanorc
        chmod -R 755 /root/.nano
        echo "Nano configuration set up successfully"
    else
        echo "Failed to set up nano configuration"
        return 1
    fi

    # Download ComfyUI related files
    cecho cyan "\n:: Downloading ComfyUI configuration files"

    # Download lists
    local list_files=(
        "common/scripts/comfy.nodes"
        "common/scripts/comfy.models"
        "common/scripts/extra.models"
    )

    for file in "${list_files[@]}"; do
        get_repo_file "$file" || return 1
    done

    # Download config files
    local config_files=(
        "common/configs/.screenrc"
        "common/configs/comfy.screenrc"
        "common/configs/comfy.settings.json"
        "common/configs/comfy.templates.json"
        "common/configs/mgr.config.ini"
    )

    for file in "${config_files[@]}"; do
        get_repo_file "$file" || return 1
    done
}

# Function to install ComfyUI and dependencies
install_comfyui() {
    cecho cyan "\n\n:::::::::::::::::::::::::::::::\n::::: Installing ComfyUI  :::::\n:::::::::::::::::::::::::::::::\n\n"

    # Change to workspace directory
    cd /workspace || {
        cecho red "Failed to change to /workspace directory"
        return 1
    }

    # Clone repositories with progress feedback
    cecho cyan ":: Cloning ComfyUI repository..."
    if ! git clone --depth 1 --progress https://github.com/comfyanonymous/ComfyUI.git; then
        cecho red "Failed to clone ComfyUI repository"
        return 1
    fi

    cd /workspace/ComfyUI/custom_nodes || {
        cecho red "Failed to change to custom_nodes directory"
        return 1
    }

    cecho cyan ":: Cloning ComfyUI-Manager repository..."
    if ! git clone --depth 1 --progress https://github.com/ltdrdata/ComfyUI-Manager.git; then
        cecho red "Failed to clone ComfyUI-Manager repository"
        return 1
    fi

    cecho green "ComfyUI and Manager cloned successfully"

    # Install Python packages with proper error handling
    cecho cyan ":: Installing Python packages..."

    # Update pip first
    if ! python -m pip install --upgrade pip; then
        cecho red "Failed to upgrade pip"
        return 1
    fi

    # Install packages with progress feedback
    local packages=(
        "--no-build-isolation flash-attn"
        "xformers torch==2.4.1+cu124 --index-url https://download.pytorch.org/whl/cu124"
        "-r /workspace/ComfyUI/requirements.txt"
        "-r /workspace/ComfyUI/custom_nodes/ComfyUI-Manager/requirements.txt"
        "comfy-cli"
    )

    for package in "${packages[@]}"; do
        cecho cyan ":: Installing: $package"
        if ! pip install "$package"; then
            cecho red "Failed to install: $package"
            return 1
        fi
    done

    # Set up ComfyUI directories and configuration
    cecho cyan ":: Setting up ComfyUI configuration..."

    # Create necessary directories
    mkdir -p "$COMFYUI_PATH"/user/default/ComfyUI-Manager || {
        cecho red "Failed to create ComfyUI directories"
        return 1
    }

    # Move configuration files
    if ! mv /root/comfy.settings.json /root/comfy.templates.json "$COMFYUI_PATH"/user/default; then
        cecho red "Failed to move ComfyUI settings files"
        return 1
    fi

    if ! cp /root/mgr.config.ini "$COMFYUI_PATH"/custom_nodes/ComfyUI-Manager/config.ini; then
        cecho red "Failed to copy manager config"
        return 1
    fi

    if ! mv /root/mgr.config.ini "$COMFYUI_PATH"/user/default/ComfyUI-Manager/config.ini; then
        cecho red "Failed to move manager config"
        return 1
    fi

    # Set up comfy-cli configuration
    mkdir -p "/root/.config/comfy-cli" || {
        cecho red "Failed to create comfy-cli config directory"
        return 1
    }

    # Create comfy-cli config file
    local config_file="/root/.config/comfy-cli/config.ini"
    if ! cat > "$config_file" << EOF
[DEFAULT]
enable_tracking = False
default_workspace = $COMFYUI_PATH
default_launch_extras =
recent_workspace = $COMFYUI_PATH
EOF
    then
        cecho red "Failed to create comfy-cli config file"
        return 1
    fi

    cecho green "ComfyUI installation and configuration completed successfully"
    return 0
}

# Function to configure ngrok and syncthing
configure_services() {
    cecho cyan "\n\n:::::::::::::::::::::::::::::::::::::::::::\n::::: Initializing ngrok & SyncThing  :::::\n:::::::::::::::::::::::::::::::::::::::::::\n\n"

    # Configure ngrok
    if [ -z "$NGROK_AUTH_TOKEN" ]; then
        cecho red "NGROK_AUTH_TOKEN must be set in order to write ngrok's configuration!"
        return 1
    fi

    mkdir -p /root/.config/ngrok || {
        cecho red "Failed to create ngrok config directory"
        return 1
    }

    # Create ngrok config file
    local ngrok_config="/root/.config/ngrok/ngrok.yml"
    if ! cat > "$ngrok_config" << EOF
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
    then
        cecho red "Failed to create ngrok config file"
        return 1
    fi

    cecho green "ngrok configuration written successfully"

    # Configure syncthing
    local scp_command="scp -P $RUNPOD_TCP_PORT_22 -i .ssh_key /path/to/config.xml root@$RUNPOD_PUBLIC_IP:/root/config.xml"
    cecho orange "For the next step, send the SyncThing config file manually via the following command:"
    cecho orange "$scp_command"
    cecho orange "Press Enter to continue afterwards. If no file is uploaded, the script will exit."
    read -r

    if [ ! -f "/root/config.xml" ]; then
        cecho red "Can't find the syncthing.config.xml file! Exiting..."
        return 1
    fi

    mkdir -p /root/.local/state/syncthing || {
        cecho red "Failed to create syncthing config directory"
        return 1
    }

    if ! mv /root/config.xml /root/.local/state/syncthing/config.xml; then
        cecho red "Failed to move syncthing config file"
        return 1
    fi

    cecho green "Syncthing configuration file moved successfully"
    return 0
}

# Initial checks
check_prerequisites

# Check installation status
if [ -f "/workspace/_INSTALL_COMPLETE" ]; then
    echo -e "\n\n::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
    echo -e "::::: Found existing installation in /workspace, will only adjust existing files :::::"
    echo -e "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n\n"
    FIRST_TIME_INSTALL=0
else
    echo -e "\n\n::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
    echo -e "::::: No existing installation was found, proceeding with first time setup :::::"
    echo -e "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n\n"
    FIRST_TIME_INSTALL=1
fi

# Stop jupyter server if it's running
echo ":: Stopping any running Jupyter server"
jupyter server stop || true

if [ $FIRST_TIME_INSTALL -eq 1 ]; then
    # Move directories to workspace
    echo ":: Moving /root, /usr/local/lib/python3.11 and /usr/local/bin to /workspace"
    mv /root /workspace
    mkdir -p /workspace/usrlocallib && chmod 755 /workspace/usrlocallib
    mv /usr/local/lib/python3.11 /workspace/usrlocallib
    mkdir -p /workspace/usrlocalbin && chmod 755 /workspace/usrlocalbin
    mv /usr/local/bin /workspace/usrlocalbin
else
    # Remove existing directories
    echo ":: Removing /root, /usr/local/lib/python3.11 and /usr/local/bin"
    rm -rf /root /usr/local/lib/python3.11 /usr/local/bin
fi

# Create symlinks
echo ":: Linking /root, /usr/local/lib/python3.11 and /usr/local/bin to their /workspace folders"
ln -s /workspace/root /root
ln -s /workspace/usrlocallib/python3.11 /usr/local/lib
ln -s /workspace/usrlocalbin/bin /usr/local

export DEBIAN_FRONTEND=noninteractive

# Install packages
install_system_packages
install_third_party_repos
install_direct_downloads

if [ $FIRST_TIME_INSTALL -eq 1 ]; then
    # Set up initial files and install ComfyUI
    setup_initial_files
    install_comfyui
    configure_services

    # Mark installation as complete
    touch /workspace/_INSTALL_COMPLETE

    # Show next steps
    cecho orange "\n:: To install the initial node collection from file: 'install_multiple_nodes /root/comfy.nodes'"
    cecho orange ":: To install the initial model collection from file: 'download_multiple_models /root/comfy.models'\n"
else
    # Just source bash aliases for existing installation
    source /root/.bash_aliases
fi

cecho green "\n\n:::::::::::::::::::::::::::::::::::::\n::::: Initialization completed. :::::\n:::::::::::::::::::::::::::::::::::::\n\n"
