#!/bin/bash
# Mute all microphones (just to be safe)

sources=($(pulsemixer --list-sources | cut -f3 | cut -d ',' -f 1 | cut -c 6-))

for id in "${sources[@]}"; do
	pulsemixer --toggle-mute --id "$id"
done

