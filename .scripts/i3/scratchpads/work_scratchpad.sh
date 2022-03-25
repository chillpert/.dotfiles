#!/bin/bash

output=$(ps ax)

name=workScratchpadProcess

if [[ $output != *"$name"* ]]; then
	st -n $name
fi
