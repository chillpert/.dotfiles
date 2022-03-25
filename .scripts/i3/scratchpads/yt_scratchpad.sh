#!/bin/bash

output=$(ps ax)

name=ytScratchpadProcess

if [[ $output != *"$name"* ]]; then
	st -n $name -e ytfzf --detach -s -S --subs=2 --sort -l 
fi
