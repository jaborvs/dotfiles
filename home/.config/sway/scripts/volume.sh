#!/bin/bash
# Usage: volume.sh up|down|mute  -- act on every audio sink (all outputs)
#   up/down: change volume by 1% (up capped at 100%)
#   mute:    toggle mute; all sinks follow the default sink's new state so they never get out of step
case "$1" in
    up)   delta='1%+' ;;
    down) delta='1%-' ;;
    mute) if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED; then state=0; else state=1; fi ;;
    *) echo "usage: $0 up|down|mute" >&2; exit 1 ;;
esac
wpctl status | awk '/^Audio/ {a=1} /^Video/ {a=0}
    a && /Sinks:/ {s=1; next} a && /Sources:|Filters:|Streams:/ {s=0}
    s && match($0, /[0-9]+\./) {print substr($0, RSTART, RLENGTH-1)}' |
while read -r id; do
    case "$1" in
        up)   wpctl set-volume -l 1.0 "$id" "$delta" ;;
        down) wpctl set-volume "$id" "$delta" ;;
        mute) wpctl set-mute "$id" "$state" ;;
    esac
done
