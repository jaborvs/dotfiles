#!/bin/bash
# Calendar reminder helper for mako.
#   on-notify (Chrome)  -> track each new Chrome notification:
#     * replace it every second with "hace MM:SS" (same id, no duplicates)
#     * left click = dismiss (tracking ends); right click = snooze (see snooze.sh):
#       the tracker re-sends it critical after the snooze and keeps counting
#     * stop at END seconds (event start)
# Replaced/re-sent notifications use app-name "calendar-reminder" so the hook
# does not fire again.

END=${REMINDER_END:-600}   # seconds after arrival when the event starts (10 min lead)
APP="calendar-reminder"
SOUND="$HOME/.local/share/sounds/modern-minimal-ui/stereo/message-new-instant.oga"
play() { setsid -f pw-play "$SOUND" >/dev/null 2>&1; }
STATE="${XDG_RUNTIME_DIR:-/tmp}/mako-reminder"
mkdir -p "$STATE"

# print "id<TAB>summary" for every Chrome notification currently shown
chrome_list() {
    makoctl list | awk '
        /^Notification [0-9]+:/ { if (id && chrome) print id "\t" sum
            id=$2; sub(":", "", id); sum=$0; sub(/^Notification [0-9]+: /, "", sum); chrome=0 }
        /App name:.*[Cc]hrom/ || /Desktop entry:.*chrom/ { chrome=1 }
        END { if (id && chrome) print id "\t" sum }'
}

exists() { makoctl list | grep -q "^Notification $1:"; }

fmt() { printf 'hace %02d:%02d' $(($1 / 60)) $(($1 % 60)); }

send() { # id summary elapsed urgency -> prints id
    notify-send -a "$APP" -p ${1:+-r "$1"} -u "$4" "$2" "$(fmt "$3")"
}

track() {
    local id="$1" sum="$2" urg=normal start now age snooze
    start=$(date +%s)
    while :; do
        now=$(date +%s); age=$((now - start))
        [ "$age" -ge "$END" ] && break
        if exists "$id"; then
            send "$id" "$sum" "$age" "$urg" >/dev/null
            sleep 1
        elif [ -f "$STATE/snooze-$id" ]; then     # right click: snoozed
            snooze=$(cat "$STATE/snooze-$id"); rm -f "$STATE/snooze-$id"
            sleep "$snooze"
            age=$(( $(date +%s) - start ))
            [ "$age" -ge "$END" ] && break
            urg=critical; id=$(send "" "$sum" "$age" critical); play
        else                                       # left click: dismissed
            break
        fi
    done
    rm -rf "$STATE/$1"
}

if [ "$1" = "--track" ]; then track "$2" "$3"; exit; fi

# entry point (hook): start a tracker for each untracked Chrome notification
chrome_list | while IFS=$'\t' read -r id sum; do
    mkdir "$STATE/$id" 2>/dev/null || continue     # atomic: already tracked
    play
    setsid -f "$0" --track "$id" "$sum" >/dev/null 2>&1
done
