#!/usr/bin/env bash
set -e

function active_monitors {
    xrandr --listactivemonitors | awk 'NR == 1 { next; } { print $4; }'
}

function connected_monitors {
    xrandr --query | awk '$2 == "connected" { print $1 }'
}

function primary_monitor {
    xrandr --listactivemonitors | awk '$2 ~ /\*/ { print $4; }'
}

function notify {
    local monitors_info=$(xrandr --query | awk '$2 == "connected" { sub(/\(.*/,""); print } ')
    notify-send -a "xrandr" "$1" "$monitors_info"
}

function mirror {
    local monitors=($(connected_monitors))
    xrandr --output ${monitors[0]} --auto
    for m in "${monitors[@]:1}"; do
        xrandr --output $m --auto --same-as ${monitors[0]}
    done
    notify "mirrored monitors"
}

function switch_primary {
    local monitors=($(active_monitors))
    local primary=$(primary_monitor)
    local new_primary_index=0

    local max_index=$((${#monitors[@]}-2))

    for i in `seq 0 $max_index`; do
        if [ "${monitors[$i]}" = $primary ]; then
            new_primary_index=$((i+1))
            break
        fi
    done

    xrandr --output ${monitors[$new_primary_index]} --primary

    notify "switched primary to ${monitors[$new_primary_index]}"
}

function toggle {
    local monitors=($(connected_monitors))
    if [ $1 -gt ${#monitors[@]} ]; then
        notify "there is no monitor $1"
        exit
    fi

    local toggle_monitor=${monitors[($1-1)]}

    if [ -z "$(xrandr --listactivemonitors | grep $toggle_monitor)" ]; then
        xrandr --output $toggle_monitor --auto
        notify "turned on $toggle_monitor"
        exit
    fi

    local active=($(active_monitors))
    if [ ${#active[@]} == 1 ]; then
        notify "$toggle_monitor is the only remaining active monitor"
        exit
    fi

    xrandr --output $toggle_monitor --off
    local message="turned off $toggle_monitor"

    if [ -z "$(primary_monitor)" ]; then
        xrandr --output ${active[0]} --primary
        message+=" and switched primary to ${active[0]}"
    fi

    notify "$message"
}

case $1 in
    "list")
        notify "monitors";;
    "mirror")
        mirror;;
    "switch_primary")
        switch_primary;;
    "toggle")
        toggle $2;;
    *)
        echo "no valid command"
        echo "valid commands are:"
        echo "  list | mirror | switch_primary | toggle <monitor>"
        exit 1;;
esac
