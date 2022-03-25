#!/bin/sh
# Author: github.com/chillpert

player_status=$(playerctl status -s)

if [ "$player_status" = "Playing" ]; then
    icon="奈" 
elif [ "$player_status" = "Paused" ]; then
    icon=" "
else
    echo "ﭦ"
	exit
fi

artist=$(playerctl metadata artist -s)
title=$(playerctl metadata title -s)

message=" $title - $artist"

if [ "$artist" = "" ]; then
	message=" $title"
fi

limit=40

if (( ${#message} > $limit )); then
	message=$(cut -c 1-$limit <<< $message)
	message=$message...
fi

echo $icon $message
