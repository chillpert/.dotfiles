#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

monitor_count=$(polybar -M | wc -l)

# Launch bar(s) depending on monitor count
if [ "$monitor_count" -eq "1" ]; then
	echo "Single monitor detected."

	polybar -q bar_left -c ~/.config/polybar/config.ini &
elif [ "$monitor_count" -gt "1" ]; then
	echo "Dual monitor detected."

	polybar -q bar_left -c ~/.config/polybar/config.ini &
	polybar -q bar_right -c ~/.config/polybar/config.ini &
else
	echo "Monitor configuration not supported."
fi

