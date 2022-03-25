#!/bin/bash

output=$(ps ax)

name=pythonScratchpadProcess

if [[ $output != *"$name"* ]]; then
	st -n $name -e python3
fi
