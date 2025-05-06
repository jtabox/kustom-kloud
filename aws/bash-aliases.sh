#!/bin/bash
# shellcheck disable=all

### Enormous (and it's an understatement) .bash_aliases file for cloud instances
# https://raw.githubusercontent.com/jtabox/kustom-kloud/main/aws/bash-aliases.sh

## lol prompt
PS1='\[\e[92;1m\]\A \[\e[94m\]\u $(if [[ $? -eq 0 ]]; then echo -e "\[\e[30;102;1m\]0"; else echo -e "\[\e[97;101;1m\]$?"; fi)\[\e[0m\] \[\e[38;5;202m\]\w \[\e[0m\]'

######################################################################## Aliases

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cd..='cd ..'
alias cd...='cd ../..'
alias apt-clean='sudo apt-get clean && apt-get autoremove'
alias apt-list-installed='sudo dpkg --get-selections'
alias cat='bat --theme="Visual Studio Dark+" --style=numbers'
alias ck='bat --theme="Visual Studio Dark+" --style=numbers'
alias cp='cp --verbose'
alias dir-diff='diff -urp'
alias epoch='date +%s'
alias grep='GREP_COLORS="mt=1;37;41" LANG=C grep --color=auto'
alias grepproc='sudo ps -aux | grep'
alias howbig='sudo du -hd 1'
alias htop='btop'
alias ip-all='sudo ip a | perl -nle"/(\d+\.\d+\.\d+\.\d+)/ && print $1"'
alias ip-ext='curl -s ifconfig.me'
alias journal-clean='sudo journalctl --vacuum-time=3d'
alias l='eza -ahMl --smart-group --icons --time-style=long-iso --group-directories-first --color-scale --git-repos'
alias ll='ls -lFah --group-directories-first --color=auto'
alias mv='mv --verbose'
alias run-ngrok='ngrok start --all'
alias run-syncthing='syncthing serve --no-browser --no-default-folder'
alias scan-host='sudo nmap -sP'
alias sccp='scp -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias show-conns='sudo ss -p | cat'
alias show-memstr='sudo dd if=/dev/mem | cat | strings'
alias show-ports='sudo lsof -Pan -i tcp -i udp'
alias sssh='ssh -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias top='btop'
alias untar='tar -xzvf'
alias updall='sudo apt-get update && apt-get upgrade -y'
alias wget-all='wget --random-wait -r -p -e robots=off -U mozilla -o $HOME/wget_all_log.txt'
alias wget='wget -c'
alias zombies='sudo ps aux | awk '\''{if ($8=="Z") { print $2 }}'\'''

####################################################################### Env vars

# Terminal colors
export CLR_CLEAR="\e[0;0m"

# Colored letters
export CLR_FG_GRAY="\e[1;30m"
export CLR_FG_RED="\e[0;31m"
export CLR_FG_GREEN="\e[1;32m"
export CLR_FG_LIGHTGREEN="\e[0;32m"
export CLR_FG_YELLOW="\e[1;33m"
export CLR_FG_ORANGE="\e[0;33m"
export CLR_FG_BLUE="\e[1;34m"
export CLR_FG_LIGHTBLUE="\e[1;36m"
export CLR_FG_CYAN="\e[0;36m"
export CLR_FG_MAGENTA="\e[1;35m"

# Colored background
export CLR_BG_BLACK="\e[0;40m"
export CLR_BG_RED="\e[0;41m"
export CLR_BG_GREEN="\e[0;42m"
export CLR_BG_BLUE="\e[0;44m"
export CLR_BG_YELLOW="\e[0;43m"
export CLR_BG_MAGENTA="\e[0;45m"
export CLR_BG_CYAN="\e[0;46m"

# Dimmed colored letters
export CLR_DFG_GRAY="\e[2;30m"
export CLR_DFG_RED="\e[2;31m"
export CLR_DFG_GREEN="\e[2;32m"
export CLR_DFG_ORANGE="\e[2;33m"
export CLR_DFG_BLUE="\e[2;34m"
export CLR_DFG_MAGENTA="\e[2;35m"
export CLR_DFG_CYAN="\e[2;36m"

# Dimmed colored background
export CLR_DBG_GRAY="\e[0;100m"
export CLR_DBG_RED="\e[0;101m"
export CLR_DBG_GREEN="\e[0;102m"
export CLR_DBG_YELLOW="\e[0;103m"
export CLR_DBG_BLUE="\e[0;104m"
export CLR_DBG_MAGENTA="\e[0;105m"
export CLR_DBG_CYAN="\e[0;106m"
export CLR_DBG_WHITE="\e[0;107m"

# Cursive colored letters
export CLR_CFG_GRAY="\e[3;30m"
export CLR_CFG_RED="\e[3;31m"
export CLR_CFG_GREEN="\e[3;32m"
export CLR_CFG_ORANGE="\e[3;33m"
export CLR_CFG_BLUE="\e[3;34m"
export CLR_CFG_MAGENTA="\e[3;35m"
export CLR_CFG_CYAN="\e[3;36m"
export CLR_CFG_WHITE="\e[3;37m"

# Cursive colored background
export CLR_CBG_BLACK="\e[3;40m"
export CLR_CBG_RED="\e[3;41m"
export CLR_CBG_GREEN="\e[3;42m"
export CLR_CBG_YELLOW="\e[3;43m"
export CLR_CBG_BLUE="\e[3;44m"
export CLR_CBG_MAGENTA="\e[3;45m"
export CLR_CBG_CYAN="\e[3;46m"

# Underlined colored letters
export CLR_UFG_GRAY="\e[4;30m"
export CLR_UFG_RED="\e[4;31m"
export CLR_UFG_GREEN="\e[4;32m"
export CLR_UFG_ORANGE="\e[4;33m"
export CLR_UFG_BLUE="\e[4;34m"
export CLR_UFG_MAGENTA="\e[4;35m"
export CLR_UFG_CYAN="\e[4;36m"
export CLR_UFG_WHITE="\e[4;37m"

# Underlined colored background
export CLR_UBG_BLACK="\e[4;40m"
export CLR_UBG_RED="\e[4;41m"
export CLR_UBG_GREEN="\e[4;42m"
export CLR_UBG_YELLOW="\e[4;43m"
export CLR_UBG_BLUE="\e[4;44m"
export CLR_UBG_MAGENTA="\e[4;45m"
export CLR_UBG_CYAN="\e[4;46m"

# Blinking colored letters
export CLR_BFG_GRAY="\e[5;30m"
export CLR_BFG_RED="\e[5;31m"
export CLR_BFG_GREEN="\e[5;32m"
export CLR_BFG_ORANGE="\e[5;33m"
export CLR_BFG_BLUE="\e[5;34m"
export CLR_BFG_MAGENTA="\e[5;35m"
export CLR_BFG_CYAN="\e[5;36m"
export CLR_BFG_WHITE="\e[5;37m"

# Blinking colored background
export CLR_BBG_BLACK="\e[5;40m"
export CLR_BBG_RED="\e[5;41m"
export CLR_BBG_GREEN="\e[5;42m"
export CLR_BBG_YELLOW="\e[5;43m"
export CLR_BBG_BLUE="\e[5;44m"
export CLR_BBG_MAGENTA="\e[5;45m"
export CLR_BBG_CYAN="\e[5;46m"


# System
export TZ='Europe/Berlin'
export LANG='C.UTF-8'
export LC_ALL='C.UTF-8'

# pip and uv settings
# export PIP_CACHE_DIR='/workspace/.cache/pip'
# export PIP_NO_CACHE_DIR='1'
# export PIP_DISABLE_PIP_VERSION_CHECK='1'
# export PIP_ROOT_USER_ACTION='ignore'
# export UV_CACHE_DIR='/workspace/.cache/uv'
# export UV_NO_CACHE='1'

####################################################################### Functions

cecho() {
    # Makes printing colored messages easier. 1st arg: see below, rest is the message
    if [ "$#" -eq 1 ]; then
        local message=${@:1}
        echo -e "${CLR_CLEAR}${message}${CLR_CLEAR}"
        return
    fi
    local message=${@:2}
    local color=${1}
    local colorvar=$CLR_CLEAR
    case $color in
    blue) colorvar=$CLR_FG_BLUE ;;
    blueb) colorvar=$CLR_BG_BLUE ;;
    cyan) colorvar=$CLR_FG_CYAN ;;
    cyanb) colorvar=$CLR_BG_CYAN ;;
    gray) colorvar=$CLR_FG_GRAY ;;
    grayb) colorvar=$CLR_BG_GRAY ;;
    green) colorvar=$CLR_FG_GREEN ;;
    greenb) colorvar=$CLR_BG_GREEN ;;
    grey) colorvar=$CLR_FG_GRAY ;;
    greyb) colorvar=$CLR_BG_GRAY ;;
    lblue) colorvar=$CLR_FG_LIGHTBLUE ;;
    lgreen) colorvar=$CLR_FG_LIGHTGREEN ;;
    magenta) colorvar=$CLR_FG_MAGENTA ;;
    magentab) colorvar=$CLR_BG_MAGENTA ;;
    orange) colorvar=$CLR_FG_ORANGE ;;
    red) colorvar=$CLR_FG_RED ;;
    redb) colorvar=$CLR_BG_RED ;;
    yellow) colorvar=$CLR_FG_YELLOW ;;
    yellowb) colorvar=$CLR_BG_YELLOW ;;
    --help) echo -e "\nMakes printing colored messages easier\n" \
        "Usage: cecho [color] <message>\n" \
        "Available colors (+b for background color instead): blue[b], cyan[b], gray[b], green[b], magenta[b], red[b], yellow[b]\n" \
        "Extra colors (with no background alternative): lblue, lgreen, orange\n" \
        "No color argument functions as a simple 'echo -e'" ;;
    *) colorvar=$CLR_CLEAR ;;
    esac
    echo -e "${colorvar}${message}${CLR_CLEAR}"
    return
}

check-port() {
    # Check if a port is bound or list all of the bound ports if no arg
    if [ -z "$1" ]; then
        cecho cyan "\nNo port specified, listing all bound ports:"
        cecho yellow "\n*** netstat:"
        sudo netstat -tulpn
        cecho yellow "\n*** lsof:"
        sudo lsof -Pan -i tcp -i udp
    else
        cecho cyan "\nChecking port $1:"
        cecho yellow "\n*** netstat:"
        sudo netstat -tulpn | grep ":$1"
        cecho yellow "\n*** lsof:"
        sudo lsof -Pan -i tcp -i udp | grep ":$1"
    fi
    cecho green '\nDone.'
}

aria-get() {
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

print-header() {
    # Overly complicated header printer
    # Usage: print-header <'type'> (always) <'main_text'> or <'text_line1'> <'text_line2'> ['text_line3']
    local type="$1"
    shift
    local color_code

    case "$type" in
    "success") color_code="$CLR_FG_GREEN" ;;
    "warn") color_code="$CLR_FG_YELLOW" ;;
    "error") color_code="$CLR_FG_RED" ;;
    "info") color_code="$CLR_FG_CYAN" ;;
    *) color_code="$CLR_FG_CYAN" ;;
    esac

    local term_width
    # The following tput fails when run in docker/a script, so we use a fallback
    term_width=$(tput cols 2>/dev/null || echo 80)
    local text_count=$#

    # One text argument
    if [ $text_count -eq 1 ]; then
        local text="$1"
        if [ ${#text} -gt "$term_width" ]; then
            echo -e "\n${color_code}${text}${CLR_CLEAR}\n"
            return
        fi

        local text_line="::::: ${text} :::::"
        local border_line
        border_line=$(printf ':%.0s' $(seq 1 ${#text_line}))

        echo -e "\n\n${color_code}${border_line}"
        echo -e "${text_line}"
        echo -e "${border_line}${CLR_CLEAR}\n\n"
        return
    fi

    # Multiple text args (2 or 3 texts)
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

    echo -e "${border_line}${CLR_CLEAR}\n\n"
}

replace-in-file-aux() {
    # Helper function for replace_in_file, does the replacing for a single file
    local filename="$1"
    local old_str="$2"
    local new_str="$3"

    if [ ! -f "$filename" ]; then
        cecho red "Error: File '$filename' not found"
        return 1
    fi

    if [ -n "$new_str" ]; then
        sed -i "s|${old_str}|${new_str}|g" "$filename"
    else
        sed -i "s|${old_str}||g" "$filename"
    fi

    if [ $? -eq 0 ]; then
        cecho green "Processed: $filename"
        return 0
    else
        cecho red "Error: Failed to modify $filename"
        return 1
    fi
}

replace-in-file() {
    # Replaces a string in a file or all files in a directory
    if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
        cecho red "Usage: replace-in-file <filename|directory> <str_to_be_replaced> <str_to_replace_with> [-y (dont_ask)]"
        return 1
    fi

    local target="$1"
    local old_str="$2"
    local new_str="$3"

    # Handle directory case
    if [ -d "$target" ] && [ "$4" != "-y" ]; then
        cecho yellow "Warning: '$target' is a directory!"
        read -p "Do you want to process all files in this directory? (y/N): " confirm
        if [[ ! $confirm =~ ^[Yy]$ ]]; then
            cecho red "Operation cancelled"
            return 0
        fi

        for file in "$target"/*; do
            if [ -f "$file" ]; then
                replace-in-file-aux "$file" "$old_str" "$new_str"
            fi
        done
        return 0
    fi

    # Handle single file case
    replace-in-file-aux "$target" "$old_str" "$new_str"
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
        find / -xdev -name "*$1*"
        cecho green "\nDone."
    fi
}

get-repo-file() {
    # Download specific files from the repo, e.g.:
    # https://raw.githubusercontent.com/jtabox/kustom-kloud/main/|--> this part: aws/some-file.txt
    local reponame
    reponame="jtabox/kustom-kloud"
    local branchname
    branchname="main"
    # Check how many args, if 2 then use arg2 as folder and filename for the output, otherwise assume the existing filename in current directory
    local outputfile
    if [ "$#" -ge 2 ]; then
        # Check if the 2nd arg is a directory or a file
        if [ -d "$2" ]; then
            outputfile="$2/$(basename "$1")"
        else
            outputfile="$2"
        fi
    else
        outputfile="./"$(basename "$1")
    fi
    cecho cyan "\n::::> Fetching $reponame/$branchname/$1 to $outputfile"
    wget -qO "$outputfile" "https://raw.githubusercontent.com/$reponame/$branchname/$1" &&
        cecho green "Done"
}

# Docker kustom functions

################## select_containers ##################
# Function for selecting one or multiple Docker containers
# Usage: select_containers [multi]
user-select-containers() {
    local dccontainers=($(docker ps -a --format "{{.Names}}"))
    if [ -z "$dccontainers" ]; then
        >&2 cecho red " No running containers were found!"
        return 1
    fi
    if [ "$1" = "multi" ]; then
        >&2 cecho orange " Choose one or more containers:"
        local selected_containers=($(printf "${CLR_FG_ORANGE}%s${CLR_CLEAR}\n" "${dccontainers[@]}" | fzf --ansi --cycle --multi))
        echo "${selected_containers[@]}"
    else
        >&2 cecho orange " Choose a container:"
        local selected_container=$(printf "${CLR_FG_ORANGE}%s${CLR_CLEAR}\n" "${dccontainers[@]}" | fzf --ansi --cycle)
        echo "$selected_container"
    fi
}

################## dpsa ##################
# Just a nicer docker ps -a
# Usage: dpsa
dpsa() {
    printf "\033[0;93m\n┌╌ Docker containers ╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌⦾\n╎\033[0;0m"
    docker ps -a --format "table {{.Names}}{{.State}}\t{{.Names}}\t{{.Status}}" \
    | sort \
    | awk '/NAMES/ {next} {
        if ($1 ~ /running/) {
            printf "\n\033[0;93m╎\033[0;0m\033[2;32m╌🟢 %-16s\033[0;0m\033[1;32m", $2;
            for (i=3;i<=NF;i++) printf "%s ", $i;
            printf "\033[0;0m"
        } else {
            printf "\n\033[0;93m╎\033[0;0m\033[2;31m╌🔴 %-16s\033[0;0m\033[1;31m", $2;
            for (i=3;i<=NF;i++) printf "%s ", $i;
            printf "\033[0;0m"
        }
    }'
    printf "\n╎\n\033[0;93m└╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌⦾\n\033[0;0m\n"
}

################## dclogs ##################
# Function for showing docker container logs
# Usage: dclogs <container> [number of lines]
dclogs() {
    # If no arguments or if 1st arg not in list of running containers, let user choose
    local dccontainers=($(docker ps -a --format "{{.Names}}"))
    if [ -z "$1" ] || [[ ! "${dccontainers[*]}" =~ "$1" ]]; then
        local dccontainer=$(user-select-containers)
        if [ -z "$dccontainer" ]; then
            cecho red " No container was selected!"
            return 1
        fi
    else
        local dccontainer=$1
    fi
    # If no 2nd argument, follow the logs
    if [ -z "$2" ]; then
        cecho green " Following logs of $dccontainer ..."
        docker logs -t -f --details "$dccontainer"
    else
        cecho green " Showing the last $2 lines of of $dccontainer ..."
        docker logs -t --tail="$2" --details "$dccontainer"
    fi
    return 0
}

################## dcsh ##################
# Function for attaching a shell on to a container
# Usage: dcsh <container> [shell]
dcsh() {
    # If no arguments or if 1st arg not in list of running containers, let user choose
    local dccontainers=($(docker ps -a --format "{{.Names}}"))
    if [ -z "$1" ] || [[ ! "${dccontainers[*]}" =~ "$1" ]]; then
        local dccontainer=$(user-select-containers)
        if [ -z "$dccontainer" ]; then
            cecho red " No container was selected!"
            return 1
        fi
    else
        local dccontainer=$1
    fi
    # If no 2nd argument, use /bin/bash as the shell
    if [ -z "$2" ]; then
        cecho green " Attaching to $dccontainer with bash ..."
        docker exec -it "$dccontainer" /bin/bash
    else
        cecho green " Attaching to $dccontainer with $2 ..."
        docker exec -it "$dccontainer" "/bin/$2"
    fi
    return 0
}

################## dc ##################
# Multi-function for docker compose containers
# Usage: dc <function> <container>
# Functions: up, down|dn, restart|rs, update|ud, updall|ua
dc() {
    # If no arguments or if 1st arg not in commands list, show available commands and let user choose
    if [ -z "$1" ] || [[ ! "up down dn restart rs update ud updall ua" =~ "$1" ]]; then
        cecho orange " Choose function:"
        local dccommands=(up down restart update updall)
        local dccommand=$(printf "${CLR_FG_ORANGE}%s${CLR_CLEAR}\n" "${dccommands[@]}" | fzf --ansi --cycle)
        if [ -z "$dccommand" ]; then
            return 1
        fi
    else
        local dccommand=$1
    fi

    cecho lgreen " Running ${dccommand} ..."

    # In regards to the 2nd argument (container name), a different logic must be used depending on $command
    # If $command is "up", then the 2nd argument isn't referring to a running container but one of the folders inside /dockerappdata
    # If $command is "down", "restart" or "update", then the 2nd argument is referring to a running container
    # If $command is "updall", then the 2nd argument is ignored and all running containers are updated
    if [ "$dccommand" = "up" ]; then
        # If no 2nd argument, or 2nd argument not in list of folders inside /dockerappdata, show list of folders and let user choose
        # Get a list of all the folders in /dockerappdata except _aux folder. We need only the folder names, not full paths
        if [ -z "$2" ] || [[ ! $(ls -d /dockerappdata/*/ | grep -v _aux | awk -F/ '{print $4}') =~ "$2" ]]; then
            cecho orange " Choose container(s):"
            local dccontainers=($(ls -d /dockerappdata/*/ | grep -v _aux | awk -F/ '{print $4}'))
            local dccontainer=($(printf "${CLR_FG_ORANGE}%s${CLR_CLEAR}\n" "${dccontainers[@]}" | fzf --ansi --cycle --multi))
            if [ -z "$dccontainer" ]; then
                return 1
            fi
        else
            local dccontainer=($2)
        fi

        # Iterate through dccontainer array and run docker compose up for each folder, checking if they contain a compose file
        for i in $dccontainer; do
            local composefile=$(ls /dockerappdata/"$i"/ | grep 'compose\.y.*ml')
            if [ "$composefile" = "" ]; then
                cecho orange " No compose file was found for $i, skipping..."
            else
                cecho green " Docker compose up: $i..."
                docker compose -f "/dockerappdata/$i/$composefile" up -d
            fi
        done
    else
        if [ "$dccommand" = "updall" ] || [ "$dccommand" = "ua" ]; then
            # No need to check for 2nd argument, just get a list of all running containers and continue
            local dccontainer=($(docker ps -a --format "{{.Names}}"))
        else
            # If no 2nd argument, or if 2nd argument not in list of running containers, let user choose
            local running_dccontainers=($(docker ps -a --format "{{.Names}}"))
            if [ -z "$2" ] || [[ ! "${running_dccontainers[*]}" =~ "$2" ]]; then
                local dccontainer=($(user-select-containers multi))
                if [ -z "$dccontainer" ]; then
                    cecho red " No container was selected!"
                    return 1
                fi
            else
                local dccontainer=($2)
            fi
        fi
        # Iterate through dccontainer array and run the necessary docker compose command for each container, checking if it's running first
        for i in "${dccontainer[@]}"; do
            if [ "$(docker ps -a --format "{{.Names}}" | grep -c "$i")" -eq 0 ]; then
                cecho red " $i wasn't found in running containers, skipping it..."
            else
                # Not all running containers have their own folder and compose files, some run as services in other compose files.
                if [ -z "/dockerappdata/$i" ]; then
                    cecho orange " $i doesn't have its own folder in /dockerappadata (probably running as service in another compose file), skipping..."
                    continue
                fi
                # Get the compose file name (docker-compose.yml, but Dockge uses compose.yaml). This assumes there is a docker compose file.
                dcfilename=$(ls /dockerappdata/"$i"/ | grep 'y*ml')
                case "$dccommand" in
                down | dn)
                    cecho green " Docker compose down: $i..."
                    docker compose -f "/dockerappdata/$i/$dcfilename" down
                    ;;
                restart | rs)
                    cecho green " Docker compose restart: $i..."
                    docker compose -f "/dockerappdata/$i/$dcfilename" restart
                    ;;
                update | ud | updall | ua)
                    cecho green " Docker compose pull & up: $i..."
                    docker compose -f "/dockerappdata/$i/$dcfilename" pull &&
                        docker compose -f "/dockerappdata/$i/$dcfilename" up -d
                    ;;
                esac
            fi
        done
    fi
    cecho green " Done!"
    return 0
}

################## dcexec ##################
# Function for running a command in a container
# Usage: dcexec <container> <command>
dcexec() {
    # If no arguments or if 1st arg not in list of running containers, let user choose
    local dccontainers=($(docker ps -a --format "{{.Names}}"))
    if [ -z "$1" ] || [[ ! "${dccontainers[*]}" =~ "$1" ]]; then
        local dccontainer=$(user-select-containers)
        if [ -z "$dccontainer" ]; then
            cecho red " No container was selected!"
            return 1
        fi
    else
        local dccontainer=$1
    fi
    # If no 2nd argument, show usage and exit
    if [ -z "$2" ]; then
        cecho red " Usage: dcexec <container> <command>"
        return 1
    else
        local command="$2"
    fi
    cecho green " Running command '$command' in $dccontainer ..."
    docker exec -it "$dccontainer" /bin/bash -c "$command"
}


export -f dpsa
export -f dclogs
export -f dcsh
export -f dc
export -f dcexec

export -f cecho
export -f check-port
export -f aria-get
export -f hrep
export -f path-add
export -f path-remove
export -f print-header
export -f replace-in-file
export -f whereis
