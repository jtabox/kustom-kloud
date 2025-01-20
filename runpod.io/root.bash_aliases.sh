#!/bin/bash
## A customized .bash_aliases I use in cloud instances - root version (no sudo)
# wget -q -O ~/.bash_aliases https://raw.githubusercontent.com/jtabox/kustom-kloud/main/runpod.io/root.bash_aliases.sh

# shellcheck disable=all

## lol prompt
PS1='\[\e[92;1m\]\A \[\e[94m\]\u $(if [[ $? -eq 0 ]]; then echo -e "\[\e[30;102;1m\]0"; else echo -e "\[\e[97;101;1m\]$?"; fi)\[\e[0m\] \[\e[38;5;202m\]\w \[\e[0m\]'

## Aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cd..='cd ..'
alias cd...='cd ../..'
alias apt-clean='apt-get clean && apt-get autoremove'
alias apt-list-installed='dpkg --get-selections'
alias cat='bat --theme="Visual Studio Dark+" --style=numbers'
alias ck='bat --theme="Visual Studio Dark+" --style=numbers'
alias cp='cp --verbose'
alias dir-diff='diff -urp'
alias epoch='date +%s'
alias grep='GREP_COLORS="mt=1;37;41" LANG=C grep --color=auto'
alias grepproc='ps -aux | grep'
alias howbig='du -hd 1'
alias htop='btop'
alias ip-all='ip a | perl -nle"/(\d+\.\d+\.\d+\.\d+)/ && print $1"'
alias ip-ext='curl -s ifconfig.me'
alias journal-clean='journalctl --vacuum-time=3d'
alias l='eza -ahMl --smart-group --icons --time-style=long-iso --group-directories-first --color-scale --git-repos'
alias ll='ls -lFah --group-directories-first --color=auto'
alias mv='mv --verbose'
alias scan-host='nmap -sP'
alias sccp='scp -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias show-conns='ss -p | cat'
alias show-mem-strings='dd if=/dev/mem | cat | strings'
alias show-ports='lsof -Pan -i tcp -i udp'
alias sssh='ssh -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias top='btop'
alias untar='tar -xzvf'
alias updall='apt-get update && apt-get upgrade -y'
alias wget-all='wget --random-wait -r -p -e robots=off -U mozilla -o $HOME/wget_all_log.txt'
alias wget='wget -c'
alias zombies='ps aux | awk '\''{if ($8=="Z") { print $2 }}'\'''

## Env vars
# Terminal color codes
export PTCLR_CLEAR="\e[0;0m"
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
export PTCLR_BG_BLUE="\e[0;44m"
export PTCLR_BG_CYAN="\e[0;46m"
export PTCLR_BG_GRAY="\e[0;40m"
export PTCLR_BG_GREEN="\e[0;42m"
export PTCLR_BG_MAGENTA="\e[0;45m"
export PTCLR_BG_RED="\e[0;41m"
export PTCLR_BG_YELLOW="\e[0;43m"

# Various
export COMFYUI_PATH=/workspace/ComfyUI
export PYTHONUNBUFFERED=1
export DEBIAN_FRONTEND=noninteractive
export TZ='Europe/Berlin'
export PIP_CACHE_DIR=/workspace/.cache/pip
export PIP_NO_CACHE_DIR=1
export PIP_DISABLE_PIP_VERSION_CHECK=1
export PIP_ROOT_USER_ACTION=ignore
export UV_CACHE_DIR=/workspace/.cache/uv
export UV_NO_CACHE=1

## Functions
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
        netstat -tulpn
    else
        cecho cyan "\nChecking port $1:"
        netstat -tulpn | grep ":$1"
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
        cecho red "Target codes:\n* inc clip ckpt lora"
        cecho red "If no target code or dir specified, the current dir is used"
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
        ["inc"]="_inc"
        ["clip"]="clip"
        ["ckpt"]="checkpoints"
        ["lora"]="loras"
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
            # If the target folder contains "$COMFYUI_PATH/models" then save the model directly, otherwise form the full path with the model name
            if [[ $outputFolder == *"$COMFYUI_PATH/models"* ]]; then
                modelFullPath="$outputFolder"
            else
                modelFullPath="${outputFolder}/${modelName}___${modelCreator}"
            fi
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

path-add() {
    # Adds <path> in PATH if it's a directory and not already in PATH
    if [ -z "$1" ]; then
        cecho red "\nAdds <path> in PATH if it's a directory and not already in PATH\nUsage: path-add <path>"
    elif [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}

path-remove() {
    # Removes <path> from PATH if it's in PATH
    if [ -z "$1" ]; then
        cecho red "\nRemoves <path> from PATH if it's in PATH\nUsage: path-remove <path>"
    else
        PATH=$(echo -n $PATH | awk -v RS=: -v ORS=: '$0 != "'"$1"'"' | sed 's/:$//')
    fi
}

subst-in-file() {
    # Substitutes a string in a file
    [ "$#" -ne 3 ] && cecho red "\nSubstitutes a string in a file\nUsage: subst-in-file <in file> <find what> <replace with>" && return
    perl -i.orig -pe 's/'"$2"'/'"$3"'/g' "$1"
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
        find "$(pwd)" -xdev -name "*$1*"
        cecho green "\nDone."
    fi
}

## misc
# those two are used in other scripts too
export -f cecho
export -f fetch_url
export -f getaimodel

# add some paths
path-add /root/.local/bin

# source keyfile (must be copied with scp from remote - not necessary with runpod, using secrets instead)
# if [ -f ~/.kleidia ]; then
#     . ~/.kleidia
# fi
