#!/bin/bash

output=$(ps ax)

name=terminalScratchpadProcess

if [[ $output != *"$name"* ]]; then
	tabbed -n $name -r 2 -t '#AF87FF' -o '#26292c' alacritty --embed ''
fi
