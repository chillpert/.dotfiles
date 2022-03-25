#!/bin/bash

# Take a screenshot
scrot /tmp/screen_locked.png -o

# Blur image
mogrify -blur 0x8 /tmp/screen_locked.png

# Lock screen displaying this image.
i3lock -i /tmp/screen_locked.png -t -u

# Turn the screen off after a delay.
#sleep 60; pgrep i3lock && xset dpms force off
