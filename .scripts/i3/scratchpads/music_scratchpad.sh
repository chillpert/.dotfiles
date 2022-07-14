#!/bin/bash

output=$(ps ax)

name=musicScratchpadProcess

if [[ $output != *"$name"* ]]; then
    # if [ ! $(pgrep "spotifyd") ]; then
    #     spotifyd
    # fi
	#
	# alacritty --class $name -e spt

    alacritty --class $name -e ncspot
fi
