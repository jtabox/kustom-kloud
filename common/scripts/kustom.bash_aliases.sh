#!/bin/bash
## A customized .bash_aliases to be downloaded and used in cloud instances
# https://raw.githubusercontent.com/jtabox/kustom-kloud/main/provscripts/kustom.bash_aliases.sh
#
# wget -q -O ~/.bash_aliases https://raw.githubusercontent.com/jtabox/kustom-kloud/main/common/kustom.bash_aliases.sh

# shellcheck disable=SC1090
# shellcheck disable=SC2142
# shellcheck disable=SC2124
# shellcheck disable=SC2035

## lol prompt
PS1='\[\e[92;1m\]\A \[\e[94m\]\u $(if [[ $? -eq 0 ]]; then echo -e "\[\e[30;102;1m\]0"; else echo -e "\[\e[97;101;1m\]$?"; fi)\[\e[0m\] \[\e[38;5;202m\]\w \[\e[0m\]'

## aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cd..='cd ..'
alias cd...='cd ../..'
alias apt-clean='sudo apt-get clean && sudo apt-get autoremove'
alias apt-get-installed-progs='sudo dpkg --get-selections'
alias ck='highlight -O xterm256 --force'
alias cp='cp --verbose'
alias dccf='docker compose config'
alias dcdn='docker compose down'
alias dcud='docker compose pull && docker compose up -d'
alias dir-diff='diff -urp'
alias dmesg='sudo dmesg'
alias dsprune='sudo docker system prune -a -f --volumes && sudo docker volume prune -a -f'
alias epoch='date +%s'
alias grep='GREP_COLORS="mt=1;37;41" LANG=C grep --color=auto'
alias grepproc='ps -aux | grep'
alias howbig='sudo du -hd 1'
alias ip-all='ip a | perl -nle"/(\d+\.\d+\.\d+\.\d+)/ && print $1"'
alias ip-ext='curl -s ifconfig.me'
alias l='eza -ahMl --smart-group --icons --time-style=long-iso --group-directories-first --color-scale --git-repos'
alias ll='ls -lFah --group-directories-first --color=auto'
alias mv='mv --verbose'
alias scan-host='nmap -sP'
alias sccp='scp -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias sccp='scp -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias show-conns='ss -p | cat'
alias show-mem-strings='sudo dd if=/dev/mem | cat | strings'
alias show-ports='sudo lsof -Pan -i tcp -i udp'
alias sssh='ssh -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias sssh='ssh -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias untar='tar -xzvf'
alias updall='sudo apt-get update && sudo apt-get upgrade -y'
alias updboot='sudo apt-get update && sudo apt-get upgrade -y && sudo reboot'
alias wget-all='wget --random-wait -r -p -e robots=off -U mozilla -o $HOME/wget_all_log.txt'
alias wget-images='wget -nd -r -l 2 -A jpg,jpeg,png,gif,bmp,webp'
alias wget='wget -c'
alias zombies='ps aux | awk '\''{if ($8=="Z") { print $2 }}'\'''

## env vars
export PTCLR_CLEAR="\e[0;0m"
# Colored letters
export PTCLR_FG_BLUE="\e[1;34m"
export PTCLR_FG_CYAN="\e[0;36m"
export PTCLR_FG_GRAY="\e[1;30m"
export PTCLR_FG_GREEN="\e[1;32m"
export PTCLR_FG_LIGHTBLUE="\e[1;36m"
export PTCLR_FG_LIGHTGREEN="\e[0;32m"
export PTCLR_FG_MAGENTA="\e[1;35m"
export PTCLR_FG_ORANGE="\e[0;33m"
export PTCLR_FG_RED="\e[0;31m"
export PTCLR_FG_YELLOW="\e[1;33m"
# Colored background
export PTCLR_BG_BLUE="\e[0;44m"
export PTCLR_BG_CYAN="\e[0;46m"
export PTCLR_BG_GRAY="\e[0;40m"
export PTCLR_BG_GREEN="\e[0;42m"
export PTCLR_BG_MAGENTA="\e[0;45m"
export PTCLR_BG_RED="\e[0;41m"
export PTCLR_BG_YELLOW="\e[0;43m"
# comfyui path
export COMFYUI_PATH=/home/user/progs/ComfyUI

## functions
cecho() {
    # Makes printing colored messages easier. 1st arg: see below, rest is the message
    if [ "$#" -eq 1 ]; then
        local message=${@:1}
        echo -e "${PTCLR_CLEAR}${message}${PTCLR_CLEAR}"
        return
    fi
    local message=${@:2}
    local color=${1}
    local colorvar=$PTCLR_CLEAR
    case $color in
    blue) colorvar=$PTCLR_FG_BLUE ;;
    blueb) colorvar=$PTCLR_BG_BLUE ;;
    cyan) colorvar=$PTCLR_FG_CYAN ;;
    cyanb) colorvar=$PTCLR_BG_CYAN ;;
    gray) colorvar=$PTCLR_FG_GRAY ;;
    grayb) colorvar=$PTCLR_BG_GRAY ;;
    green) colorvar=$PTCLR_FG_GREEN ;;
    greenb) colorvar=$PTCLR_BG_GREEN ;;
    grey) colorvar=$PTCLR_FG_GRAY ;;
    greyb) colorvar=$PTCLR_BG_GRAY ;;
    lblue) colorvar=$PTCLR_FG_LIGHTBLUE ;;
    lgreen) colorvar=$PTCLR_FG_LIGHTGREEN ;;
    magenta) colorvar=$PTCLR_FG_MAGENTA ;;
    magentab) colorvar=$PTCLR_BG_MAGENTA ;;
    orange) colorvar=$PTCLR_FG_ORANGE ;;
    red) colorvar=$PTCLR_FG_RED ;;
    redb) colorvar=$PTCLR_BG_RED ;;
    yellow) colorvar=$PTCLR_FG_YELLOW ;;
    yellowb) colorvar=$PTCLR_BG_YELLOW ;;
    --help) echo -e "\nMakes printing colored messages easier\n" \
        "Usage: cecho [color] <message>\n" \
        "Available colors (+b for background color instead): blue[b], cyan[b], gray[b], green[b], magenta[b], red[b], yellow[b]\n" \
        "Extra colors (with no background alternative): lblue, lgreen, orange\n" \
        "No color argument functions as a simple 'echo -e'" ;;
    *) colorvar=$PTCLR_CLEAR ;;
    esac
    echo -e "${colorvar}${message}${PTCLR_CLEAR}"
    return
}

check-port() {
    # Check if a port is bound or list all of the bound ports if no arg
    if [ -z "$1" ]; then
        cecho cyan "\nNo port specified, listing all bound ports:"
        sudo netstat -tulpn
    else
        cecho cyan "\nChecking port $1:"
        sudo netstat -tulpn | grep ":$1"
    fi
    cecho green '\nDone.'
}

fetch_url() {
    # Uses aria2c to download a file from a URL
    if [ $# -eq 0 ]; then
        cecho red "\nUses aria2c to download a file from a URL\nUsage: fetch_url <url> [target_dir (current dir if not specified)]"
        return
    elif [ $# -eq 1 ]; then
        target_dir="$(pwd)"
    else
        target_dir="$2"
    fi
    aria2c --continue=true --split=16 --max-connection-per-server=16 --min-split-size=1M --max-concurrent-downloads=1 --file-allocation=falloc --console-log-level=error --summary-interval=0 --dir="$target_dir" "$1"
    return
}

getaimodel() {
    # Downloader for AI models that uses appropriate API_KEYs and creates and saves in appropriate folder names
    # Check if the 2 needed environment variables are set
    if [[ -z $HF_TOKEN || -z $CIVITAI_API_KEY ]]; then
        cecho red "Error! HF_TOKEN and/or CIVITAI_API_KEY environment variable not set!"
        return 1
    fi
    # Check if at least the model-url argument is given
    if [[ $# -lt 1 ]]; then
        cecho red "\nError! No download URL specified!"
        cecho red "Usage: getaimodel <model-complete-url> [target-code/dir]"
        cecho red "Target codes:\n* inc\n* (ckpt | lora)-(flux | pdxl | sdxl | sd15)"
        return 1
    fi

    # If only the model-url is given, set the target dir to the current directory
    if [[ $# -lt 2 ]]; then
        targetCode="$(pwd)"
    else
        targetCode="$2"
    fi
    aiBaseFolder="$COMFYUI_PATH/models"
    declare -A modelFolders=(
        ["inc"]="inc"
        ["ckpt-flux"]="checkpoints/Flux"
        ["ckpt-pdxl"]="checkpoints/PDXL"
        ["ckpt-sd15"]="checkpoints/SD15"
        ["ckpt-sdxl"]="checkpoints/SDXL"
        ["lora-flux"]="loras/Flux"
        ["lora-pdxl"]="loras/PDXL"
        ["lora-sd15"]="loras/SD15"
        ["lora-sdxl"]="loras/SDXL"
    )
    # Check if the target code is a valid key in the modelFolders dictionary
    if [[ -v modelFolders[$targetCode] ]]; then
        outputFolder="$aiBaseFolder/${modelFolders[$targetCode]}"
    else
        outputFolder="$targetCode"
    fi

    # Model is from HuggingFace
    if [[ $1 == *"huggingface.co"* || $1 == *"hf.co"* ]]; then
        # Figure out if it's repo or file download, from the amount of url parts
        IFS='/' read -r -a urlParts <<<"$1"
        if [[ ${#urlParts[@]} -le 7 ]]; then
            # Hopefully a repo download (either 5 or 7 parts, depending on if branch is included)
            modelCreator=${urlParts[3]}
            modelName=${urlParts[4]}
            modelFullPath="${outputFolder}/${modelName}___${modelCreator}"
            cecho green "\nDownloading whole model repo:"
            cecho green "From: HuggingFace"
            cecho green "Repo: $modelName"
            cecho green "To:   $modelFullPath\n"

            if [[ -d $modelFullPath && $(ls -A "$modelFullPath") ]]; then
                # There already exists a non-empty folder with that name, git clone will complain
                cecho orange "Warning! A non-empty folder with the same name exists already:\n'$modelFullPath'"
                cecho orange "The folder and its contents will be deleted if you proceed so that git clone doesn't complain. Make sure you've backed it up as necessary before continuing here.\nProceed? - [y]/n :: "
                read -r userResponse
                if [[ ${userResponse,,} == 'n' ]]; then
                    cecho red "\nExiting..."
                    return 1
                else
                    rm -rf "$modelFullPath"
                fi
            fi
            # Clone the model repo using git
            git clone --depth=1 --recurse-submodules --shallow-submodules --single-branch --jobs=16 --progress "$1" "$modelFullPath"
        else
            # File download (8 parts, with the file name at the end)
            # Parse the URL to get the model creator, name, and file name
            IFS='/' read -r -a urlParts <<<"$1"
            modelCreator=${urlParts[3]}
            modelName=${urlParts[4]}
            modelFile=${urlParts[7]}
            # For HuggingFace models, also form the full path with the model name
            modelFullPath="${outputFolder}/${modelName}___${modelCreator}"
            cecho red "\nDownloading specific model file:"
            cecho red "From: HuggingFace"
            cecho red "File: $modelFile"
            cecho red "To:   $modelFullPath\n"

            if [[ ! -d $modelFullPath ]]; then
                mkdir -p "$modelFullPath"
            fi
            # Download the model using aria2c
            aria2c --header="Authorization: Bearer $HF_TOKEN" --continue=true --split=16 --max-connection-per-server=16 --min-split-size=1M --max-concurrent-downloads=1 --file-allocation=falloc --console-log-level=error --summary-interval=0 --dir="$modelFullPath" --out="$modelFile" "$1"
        fi
        return 0
    fi

    # Model is from CivitAI
    if [[ $1 == *"civitai.com"* ]]; then
        cecho green "\nStarting download:"
        cecho green "From: CivitAI"
        cecho green "To:   $outputFolder\n"
        # Form the url with token
        modelUrl="$1&token=$CIVITAI_API_KEY"
        # Download the model using aria2c
        aria2c --continue=true --split=16 --max-connection-per-server=16 --min-split-size=1M --max-concurrent-downloads=1 --file-allocation=falloc --console-log-level=error --summary-interval=0 --dir="$outputFolder" "$modelUrl"
        return 0
    fi

    # If the URL doesn't match any of the known patterns, just assume it's a direct download
    cecho green "\nStarting download:"
    cecho green "From: Unidentified Direct URL"
    cecho green "To:   $outputFolder\n"
    # Download the model using aria2c
    aria2c --continue=true --split=16 --max-connection-per-server=16 --min-split-size=1M --max-concurrent-downloads=1 --file-allocation=falloc --console-log-level=error --summary-interval=0 --dir="$outputFolder" "$1"
    return 0
}

hrep() {
    # history grep
    history | GREP_COLORS="mt=1;37;41" LANG=C grep --color=auto -i "$@"
}

mb() {
    # mamba wrapper wannabe
    if [ "$1" = "d" ]; then
        cecho
        cecho yellowb "** Deactivate current environment (${CONDA_DEFAULT_ENV}) **"
        mamba deactivate
        cecho lgreen "\nUsing:\nPython from $(which python3)\nPip from $(which pip)"
        return 0
    elif [ "$1" = "e" ]; then
        cecho
        cecho greenb "** List conda envs **"
        mamba env list
        return 0
    elif [ "$1" = "u" ]; then
        cecho
        cecho yellowb "** Update all main packs **"
        mamba update --all
        return 0
    elif [ "$1" = "c" ]; then
        cecho
        cecho yellowb "** Cleaning caches & lockfiles **"
        mamba clean --all --trash -y -v
        return 0
    elif [ -z "$1" ]; then
        local env_to_activate="base"
    elif [[ $1 == "10" || $1 == "11" || $1 == "12" ]]; then
        local env_to_activate="p3$1"
    else
        local env_to_activate="$1"
    fi
    cecho
    cecho blueb "** Activate env $env_to_activate **"
    cecho yellow "Deactivating current env ..."
    mamba deactivate
    cecho blue "Activating $1 ..."
    mamba activate "$1"
    cecho lgreen "\nNow using:\nPython from $(which python)\nPip from $(which pip)"
}

path-add() {
    # Adds <path> in PATH if it's a directory and not already in PATH
    if [ -z "$1" ]; then
        cecho red "\nAdds <path> in PATH if it's a directory and not already in PATH\nUsage: path-add <path>"
    elif [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}

subst-in-file() {
    # Substitutes a string in a file
    [ "$#" -ne 3 ] && cecho red "\nSubstitutes a string in a file\nUsage: subst-in-file <in file> <find what> <replace with>" && return
    perl -i.orig -pe 's/'"$2"'/'"$3"'/g' "$1"
}

where-in-files() {
    # Looks for <pattern> in files in current directory
    if [ -z "$1" ]; then
        cecho red "\nLooks for <pattern> in files in current directory\nUsage: where-in-files <pattern>"
    else
        cecho yellow "Looking for $1 in current directory's files..."
        grep -RnisI "$1" *
    fi
}

whereis() {
    # Looks up the file/dir with wildcards
    if [ -z "$1" ]; then
        cecho red "\nWhere's what?"
    else
        cecho yellow "\nLooking for $1..."
        cecho yellow "* which:"
        which "$1"
        cecho yellow "* find:"
        sudo find "$(pwd)" -xdev -name "*$1*"
        cecho green "\nDone."
    fi
}

## misc
# those two are used in other scripts too
export -f cecho
export -f fetch_url

# add some paths
path-add /home/user/progs/system
path-add /home/user/.local/bin

# source keyfile
if [ -f ~/.kleidia ]; then
    . ~/.kleidia
fi

# completions
if command -v ngrok &>/dev/null; then
    eval "$(ngrok completion)"
fi
