#!/bin/bash

# Helper script that downloads files from various sources. Is sourced by other scripts.

# Mappings
source /opt/ai-dock/storage_monitor/etc/mappings.sh

# rclone_download <target_dir> <file>
function rclone_download {
    local target_dir=$1
    local file=$2
    local source_file=$RCLONE_REMOTE:$file
    local target_file
    target_file="${WORKSPACE}storage/stable_diffusion/models/$target_dir/"$(basename "$file")

    cecho yellow "Downloading and symlinking $source_file to $target_file"
    rclone copy "$source_file" "$target_file"

    # Symlink
    local storage_map_key="stable_diffusion/models/$target_dir"
    ln -s "$target_file" "${storage_map["$storage_map_key"]}"

    cecho green "Done."

    return
}

# other_download <url> <target dir>
function other_download {
    # use tokens by default (RUNPOD_SECRET_HF_TOKEN, RUNPOD_SECRET_CIVITAI_TOKEN)
    if [[ $1 =~ ^https://([a-zA-Z0-9_-]+\.)?huggingface\.co(/|$|\?) ]]; then
        auth_token="$RUNPOD_SECRET_HF_TOKEN"
    elif [[ $1 =~ ^https://([a-zA-Z0-9_-]+\.)?civitai\.com(/|$|\?) ]]; then
        auth_token="$RUNPOD_SECRET_CIVITAI_TOKEN"
    fi

    wget --header="Authorization: Bearer $auth_token" -qnc --content-disposition --show-progress -e dotbytes=4M -P "$2" "$1"

    return
}