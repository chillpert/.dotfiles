#!/bin/bash
# Credit: Luke Smith

# Confirm anything with dmenu
# ./dmenu_confirm "Do you want to shutdown?" "shutdown -h now"

#[ $(echo -e "No\nYes" | dmenu -nf '#FFFFFF' -sb '#af87ff' -sf '#FFFFFF' -nb '#262626' -i -fn 'VL PGothic-11.5' -l 2 -p "$1") == "Yes" ] && $2
[ $(echo -e "No\nYes" | dmenu -nf '#FFFFFF' -sb '#af87ff' -sf '#FFFFFF' -nb '#262626' -i -fn 'VL PGothic-11.5' -m 0 -p "$1") == "Yes" ] && $2
