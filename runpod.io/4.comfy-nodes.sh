#!/bin/bash
# shellcheck disable=SC1091
# A series of scripts that install packages, ComfyUI, configure and download files and start up apps.
# 3: ComfyUI nodes installation - root version (no sudo) for runpod.io
# wget https://raw.githubusercontent.com/jtabox/kustom-kloud/main/runpod.io/3.comfy-nodes.sh && chmod +x 3.comfy-nodes.sh

# set -e          # Exit on error - we want the script to continue if a node fails to install
set -u          # Exit on using unset variable
set -o pipefail # Exit on pipe error

cecho cyan "\n::::: Starting ComfyUI nodes installation  :::::\n\n"

if [ -z "$COMFYUI_PATH" ]; then
    cecho red "COMFYUI_PATH must be set to continue. Exiting..."
    exit 1
fi

if [ ! -d "$COMFYUI_PATH" ]; then
    cecho red "Can't find the ComfyUI directory at $COMFYUI_PATH! Exiting..."
    exit 1
fi

if ! command -v comfy &> /dev/null; then
    cecho red "The 'comfy' command is not available! Exiting..."
    exit 1
fi

if [ ! -f "/root/comfy.nodes" ]; then
    cecho red "Can't find the comfy.nodes file! Exiting..."
    exit 1
fi

source /root/comfy.nodes

cecho green "Imported list with ${#COMFY_NODES[@]} nodes, starting installation ...\n"

# Define the group size
GROUP_SIZE=20

# Calculate the number of groups needed
TOTAL_NODES=${#COMFY_NODES[@]}
NUM_GROUPS=$(( (TOTAL_NODES + GROUP_SIZE - 1) / GROUP_SIZE ))

# Loop through each group and install the nodes
for ((i=0; i<NUM_GROUPS; i++)); do
    START_INDEX=$((i * GROUP_SIZE))
    END_INDEX=$((START_INDEX + GROUP_SIZE))

    # Ensure END_INDEX does not exceed the total number of nodes
    if [ "$END_INDEX" -gt "$TOTAL_NODES" ]; then
        END_INDEX="$TOTAL_NODES"
    fi

    # Calculate the length of the current group
    GROUP_LENGTH=$((END_INDEX - START_INDEX))

    # Slice the array to get the current group of nodes
    CURRENT_GROUP=("${COMFY_NODES[@]:START_INDEX:GROUP_LENGTH}")

    # Form the command for the current group
    nodes_command="comfy node install ${CURRENT_GROUP[*]}"

    # Run the command
    cecho orange "Running command for group $((i+1)) of $NUM_GROUPS ..."
    $nodes_command
done

cecho green "\n\n::::: Finished installing ComfyUI nodes :::::\n"
cecho yellow "::::: Next step :::::"
cecho yellow "::::: - | ./5.comfy-models.sh | - to download ComfyUI models :::::\n"