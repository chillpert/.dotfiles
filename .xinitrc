# In case you want to go with the normal Gnome login, run:
# $ sudo systemctl start gdm.service
# $ sudo systemctl enable gdm.service

#exec gnome-session
#return

# Set up monitors
nvidia-settings --load-config-only &
nvidia-settings --assign CurrentMetaMode="HDMI-0: nvidia-auto-select +1920+0 {rotation=right}, DVI-D-0: nvidia-auto-select +0+420"

# Consistent cursor size
#xrandr --dpi 140
xrandr --dpi 96
#xrdb -merge ~/.Xresources
[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources
Xcursor.size: 64

# Disable mouse acceleration (because this desktop is not for soy gamers)
xinput --set-prop 'Kingsis Peripherals ZOWIE Gaming mouse' 'libinput Accel Profile Enabled' 0

# IBus fix
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus

# Enable IBus for Japanse
ibus-daemon &

# WM
exec i3
#exec dwm
