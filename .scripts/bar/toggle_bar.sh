#!/bin/bash
# Author: Chillpert

program="polybar"

ps_out=`ps -ef | grep $program | grep -v 'grep' | grep -v $0`

result=$(echo $ps_out | grep "$program")

if [[ "$result" != "" ]];then
    echo "Running"
    killall polybar
else
    echo "Not Running"
    source ~/.config/polybar/launch.sh
fi
