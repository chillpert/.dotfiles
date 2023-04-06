#!/bin/sh
# Show tiramisu notifications in polybar.

# How many seconds notification is displayed:
display_duration=5.0

# Maximum number of characters:
char_limit=30

# Replace app names with nerd font logos
use_nerd_font="false"

notifications=~/.scripts/polybar/notifications/
sound=notification.mp3

# Stop old tiramisu processes if any:
pgrep -x tiramisu >/dev/null && killall tiramisu

# Start a new tiramisu process:
tiramisu -o '#source!%!summary!%!#body!%!#hints' |
    while read -r line; do
        separator="!%!"
        tmp=${line//"$separator"/$'\2'}
        IFS=$'\2' read -a arr <<< "$tmp"

        if [[ "${arr[0]}" == "Signal" ]]; then
            line="New Signal message"
            # Mute signal as it has its own notification sound
            sound=""
        elif [[ "${arr[0]}" == "discord" ]]; then
            line="${arr[0]}: ${arr[2]}"
            # Mute discord as it has its own notification sound
            sound=""
        # If notify is from Unreal Engine, play compile sounds used when hot-reloading
        elif [[ "${arr[0]}" == "UE" ]]; then
            line="${arr[0]}: ${arr[2]}"
            if [[ "${arr[3]}" == *"success=1"* ]]; then
                sound=CompileSuccess.WAV
            elif [[ "${arr[3]}" == *"success=0"* ]]; then
                sound=CompileFailed.WAV
            fi
        else
            line="${arr[0]}: ${arr[2]}"
        fi
        
        # Cut notification by character limit:
        if [ "${#line}" -gt "$char_limit" ]; then
            line="$(echo "$line" | cut -c1-$((char_limit-1)))…"
        fi

        if [[ ! -z "$sound" ]]; then
            mpv --quiet --ytdl=no $notifications$sound --start=00:00 &
        fi

        # Display notification for the duration time:
        echo "  $line"
        sleep "$display_duration"
        echo " "
    done
