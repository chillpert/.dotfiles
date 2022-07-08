#!/bin/bash

output=$(ps ax)

name=musicScratchpadProcess

if [[ $output != *"$name"* ]]; then
	alacritty --class $name
fi
