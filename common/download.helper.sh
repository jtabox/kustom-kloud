#!/bin/bash

# Helper script for downloading various files from various sources. Is sourced by other scripts.

# fetch_url <url> [target dir]
# depending on the url, downloads the file with the appropriate token, or from hetzner storage
function fetch_url {
    if [ $# -eq 0 ]; then
        cecho red "Usage: fetch_url <url> [target_dir (current dir if not specified)]"
        return
    fi
    if [[ $1 =~ ^https://([a-zA-Z0-9_-]+\.)?huggingface\.co(/|$|\?) ]]; then
        auth_token="$HF_TOKEN"
    elif [[ $1 =~ ^https://([a-zA-Z0-9_-]+\.)?civitai\.com(/|$|\?) ]]; then
        auth_token="$CIVITAI_API_KEY"
    else
        auth_token=""
    fi
    if [ $# -eq 1 ]; then
        target_dir="."
    else
        target_dir="$2"
    fi
    if auth_token; then
        wget --header="Authorization: Bearer $auth_token" -qnc --content-disposition --show-progress -e dotbytes=4M -P "$target_dir" "$1"
    else
        rclone copy -P "${HETZ_DRIVE}:$1" "$target_dir"
    fi
    return
}
