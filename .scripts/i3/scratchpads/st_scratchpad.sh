#!/bin/bash

output=$(ps ax)

name=stScratchpadProcess

if [[ $output != *"$name"* ]]; then
	tabbed -n $name -r 2 -t '#AF87FF' -o '#262626' st -w ''
fi
