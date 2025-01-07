#!/bin/bash
# A customized .bash_aliases to be downloaded and used in the provisioning scripts for AI-Dock containers
# https://raw.githubusercontent.com/jtabox/kustom-kloud/main/provscripts/kustom.bash_aliases.sh
#

# lol
PS1='\[\e[92;1m\]\A \[\e[0;94m\]\h\[\e[36m\].\[\e[94m\]\u $(if [[ $? -eq 0 ]]; then echo -e "\[\e[30;102;1m\]0"; else echo -e "\[\e[97;101;1m\]$?"; fi)\[\e[0m\] \[\e[38;5;202m\]\w \[\e[0m\]'

# aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cd..='cd ..'
alias cd...='cd ../..'
alias ck='highlight -O xterm256 --force'
alias cp='cp --verbose'
alias dir-diff='diff -urp'
alias apt-get-installed-progs='sudo dpkg --get-selections'
alias grep='GREP_COLORS="mt=1;37;41" LANG=C grep --color=auto'
alias grepproc='ps -aux | grep'
alias howbig='sudo du -hd 1'
alias ip-ext='curl -s ifconfig.me'
alias l='eza -ahMl --smart-group --icons --time-style=long-iso --group-directories-first --color-scale --git-repos'
alias mv='mv --verbose'
alias sssh='ssh -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias sccp='scp -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias untar='tar -xzvf'
alias wget-all='wget --random-wait -r -p -e robots=off -U mozilla -o $HOME/wget_all_log.txt'
alias wget-images='wget -nd -r -l 2 -A jpg,jpeg,png,gif,bmp,webp'
alias wget='wget -c'

# constants
export PTCLR_CLEAR="\e[0;0m"

# Colored letters
export PTCLR_FG_GRAY="\e[1;30m"
export PTCLR_FG_RED="\e[0;31m"
export PTCLR_FG_GREEN="\e[1;32m"
export PTCLR_FG_LIGHTGREEN="\e[0;32m"
export PTCLR_FG_YELLOW="\e[1;33m"
export PTCLR_FG_ORANGE="\e[0;33m"
export PTCLR_FG_BLUE="\e[1;34m"
export PTCLR_FG_LIGHTBLUE="\e[1;36m"
export PTCLR_FG_CYAN="\e[0;36m"
export PTCLR_FG_MAGENTA="\e[1;35m"
# Colored background
export PTCLR_BG_GRAY="\e[0;40m"
export PTCLR_BG_RED="\e[0;41m"
export PTCLR_BG_GREEN="\e[0;42m"
export PTCLR_BG_BLUE="\e[0;44m"
export PTCLR_BG_YELLOW="\e[0;43m"
export PTCLR_BG_MAGENTA="\e[0;45m"
export PTCLR_BG_CYAN="\e[0;46m"

export COMFYUI_PATH="/opt/ComfyUI"

# functions
################## colored echo
# Makes printing colored messages easier. 1st arg: see below, rest is the message
cecho () {
    # shellcheck disable=SC2124
    local message=${@:2}
    local color=${1}
    local colorvar=$PTCLR_CLEAR
    case $color in
        gray) colorvar=$PTCLR_FG_GRAY;;
        grey) colorvar=$PTCLR_FG_GRAY;;
        red) colorvar=$PTCLR_FG_RED;;
        green) colorvar=$PTCLR_FG_GREEN;;
        lgreen) colorvar=$PTCLR_FG_LIGHTGREEN;;
        yellow) colorvar=$PTCLR_FG_YELLOW;;
        orange) colorvar=$PTCLR_FG_ORANGE;;
        blue) colorvar=$PTCLR_FG_BLUE;;
        lblue) colorvar=$PTCLR_FG_LIGHTBLUE;;
        cyan) colorvar=$PTCLR_FG_CYAN;;
        magenta) colorvar=$PTCLR_FG_MAGENTA;;
        grayb) colorvar=$PTCLR_BG_GRAY;;
        greyb) colorvar=$PTCLR_BG_GRAY;;
        redb) colorvar=$PTCLR_BG_RED;;
        greenb) colorvar=$PTCLR_BG_GREEN;;
        blueb) colorvar=$PTCLR_BG_BLUE;;
        yellowb) colorvar=$PTCLR_BG_YELLOW;;
        magentab) colorvar=$PTCLR_BG_MAGENTA;;
        cyanb) colorvar=$PTCLR_BG_CYAN;;
        *) colorvar=$PTCLR_CLEAR;;
    esac
    echo
    echo -e "${colorvar}${message}${PTCLR_CLEAR}"
    echo
    return
}


# Looks up the file/dir with wildcards
whereis () {
    if [ -z "$1" ]; then
        cecho red "Where's what?"
    else
        cecho yellow "Looking for $1..."
        cecho yellow "which :"
        which "$1"
        cecho yellow "find :"
        sudo find "$(pwd)" -xdev -name "*$1*"
        cecho green "Done."
    fi
}

# Substitutes a string in a file
function subst-in-file {
  [ "$#" -ne 3 ] && cecho red "Usage:\nsubst-in-file <in file> <find what> <replace with>" && exit 1
  perl -i.orig -pe 's/'"$2"'/'"$3"'/g' "$1"
}

# Looks for <pattern> in files in current directory
function where-in-files {
  grep -RnisI "$1" *
}

# fetch_url <url> [target dir]
# depending on the url, downloads the file with the appropriate token, or from hetzner storage
function fetch_url {
    if [ $# -eq 0 ]; then
        cecho red "Usage: fetch_url <url> [target_dir (current dir if not specified)]"
        return
    elif [ $# -eq 1 ]; then
        target_dir="$(pwd)"
    else
        target_dir="$2"
    fi

    if [[ $1 =~ ^https://([a-zA-Z0-9_-]+\.)?huggingface\.co(/|$|\?) ]]; then
        wget --header="Authorization: Bearer $HF_TOKEN" -qnc --content-disposition --show-progress -e dotbytes=4M -P "$target_dir" "$1"
    elif [[ $1 =~ ^https://([a-zA-Z0-9_-]+\.)?civitai\.com(/|$|\?) ]]; then
        # AI-Dock uses $CIVITAI_TOKEN, but the official used everywhere else is $CIVITAI_API_KEY
        if [ "$CIVITAI_API_KEY" = "" ]; then CIVITAI_API_KEY=$CIVITAI_TOKEN; fi
        full_url="$1&token=${CIVITAI_API_KEY}"
        aria2c --continue=true --split=16 --max-connection-per-server=16 --min-split-size=1M --max-concurrent-downloads=1 --dir="$target_dir" "$full_url"
    else
        # hetzner no longer available
        #rclone copy -P "${HETZ_DRIVE}:$1" "$target_dir"
        cecho red "Couldn't parse URL: $1"

    fi
    return
}

export -f cecho
export -f fetch_url
