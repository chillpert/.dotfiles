#!/bin/bash

output=$(ps ax)

name=pythonScratchpadProcess

if [[ $output != *"$name"* ]]; then
	alacritty --class $name -e python3
fi
