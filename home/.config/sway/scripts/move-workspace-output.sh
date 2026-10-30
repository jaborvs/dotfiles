#!/bin/bash
current=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')
outputs=($(swaymsg -t get_outputs | jq -r '.[] | select(.active) | .name'))
for i in "${!outputs[@]}"; do
    if [[ "${outputs[$i]}" == "$current" ]]; then
        next=$(( (i + 1) % ${#outputs[@]} ))
        swaymsg move workspace to output "${outputs[$next]}"
        exit 0
    fi
done
