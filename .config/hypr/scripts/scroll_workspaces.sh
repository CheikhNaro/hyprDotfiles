#!/bin/bash
# Usage: scroll_workspaces.sh <next|prev> [move]

DIR=$1
ACTION=${2:-focus}

CURRENT_MONITOR=$(hyprctl activeworkspace -j | jq -r '.monitor')
CURRENT=$(hyprctl activeworkspace -j | jq '.id')
WORKSPACES=($(hyprctl workspaces -j | jq -r --arg mon "$CURRENT_MONITOR" '[.[] | select(.id > 0 and .monitor == $mon)] | sort_by(.id) | .[].id'))

INDEX=-1
for i in "${!WORKSPACES[@]}"; do
    if [[ "${WORKSPACES[$i]}" == "$CURRENT" ]]; then
        INDEX=$i
        break
    fi
done

if [[ "$DIR" == "next" ]]; then
    NEW_INDEX=$((INDEX + 1))
    if [[ $NEW_INDEX -lt ${#WORKSPACES[@]} ]]; then
        TARGET=${WORKSPACES[$NEW_INDEX]}
    else
        exit 0
    fi
elif [[ "$DIR" == "prev" ]]; then
    NEW_INDEX=$((INDEX - 1))
    if [[ $NEW_INDEX -ge 0 ]]; then
        TARGET=${WORKSPACES[$NEW_INDEX]}
    else
        exit 0
    fi
fi

if [[ "$ACTION" == "move" ]]; then
    hyprctl dispatch "hl.dsp.window.move({ workspace = $TARGET })"
else
    hyprctl dispatch "hl.dsp.focus({ workspace = $TARGET })"
fi
