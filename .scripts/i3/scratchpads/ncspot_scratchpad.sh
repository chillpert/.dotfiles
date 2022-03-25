#!/bin/bash

output=$(ps ax)

name=spotScratchpadProcess

if [[ $output != *"$name"* ]]; then
	#st -n $name -e zsh -c 'cmus | cat - /dev/tty'
	st -n $name 
fi
