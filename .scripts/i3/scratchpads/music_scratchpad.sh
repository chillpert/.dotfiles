#!/bin/bash

output=$(ps ax)

name=musicScratchpadProcess

if [[ $output != *"$name"* ]]; then
	#st -n $name -e zsh -c 'cmus | cat - /dev/tty'
	st -n $name 
fi
