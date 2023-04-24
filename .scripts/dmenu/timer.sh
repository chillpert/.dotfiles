#!/bin/bash

minutes=$(printf '' | dmenu -i -fn 'VL PGothic-11.5' -p 'Timer (Minutes)') "$@" || exit

sleep ${minutes}m
# Only play alarm for 10 seconds
timeout 14 mpv --quiet --ytdl=no ~/.scripts/dmenu/free-software-song.au --start=00:00 --no-terminal &

# Some visual feedback
xrandr-invert-colors
sleep 5
xrandr-invert-colors

