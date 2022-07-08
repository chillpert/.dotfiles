#!/bin/bash

output=$(ps ax)

name=terminalScratchpadProcess

if [[ $output != *"$name"* ]]; then
    alacritty --class $name -e tmux
fi
