#!/bin/bash

output=$(ps ax)

name=stScratchpadProcess

if [[ $output != *"$name"* ]]; then
	st -n $name
fi
