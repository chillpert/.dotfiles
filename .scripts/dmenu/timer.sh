#!/bin/bash

minutes=$(printf '' | dmenu -nf '#FFFFFF' -sb '#af87ff' -sf '#FFFFFF' -nb '#262626' -i -fn 'VL PGothic-11.5' -p 'Timer (Minutes)') "$@" || exit

sleep ${minutes}m
# Only play alarm for 10 seconds
timeout 14 mpv --quiet --ytdl=no ~/.local/bin/scripts/free-software-song.au --start=00:00

