#!/bin/bash
layout=$(swaymsg -t get_inputs | jq -r '[.[] | select(.type == "keyboard") | .xkb_active_layout_name] | first')
printf '%s' "$layout" | grep -oP '\(.*?\)' | tr -d '()' | sed 's/, /_/; s/\.//' | tr '[:upper:]' '[:lower:]'
