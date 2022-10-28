#!/bin/bash
# Author: Chillpert

IFS='%'

# Mic status
sample=($(pulsemixer --list-sources | cut -f3 | cut -d ',' -f 1 | cut -c 6- | head -n 1))
isMute=$(pulsemixer --id "$sample" --get-mute)

mic_msg=''
bt_msg=''
lan_msg=''

if (($isMute == 1)); then
	mic_msg=""
fi

# Internet connection status
{
	if ping -q -c 1 -W 1 8.8.8.8 >/dev/null; then
		continue
	else
		lan_msg+=""
	fi
} 2> /dev/null

echo $mic_msg $lan_msg

unset IFS
