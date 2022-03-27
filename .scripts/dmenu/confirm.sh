#!/bin/bash
# Credit: Luke Smith

# Confirm anything with dmenu
# ./dmenu_confirm "Do you want to shutdown?" "shutdown -h now"

[ $(echo -e "No\nYes" | dmenu -i -fn 'VL PGothic-11.5' -m 0 -p "$1") == "Yes" ] && $2
