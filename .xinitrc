# Set up monitors
nvidia-settings --load-config-only &
nvidia-settings --assign CurrentMetaMode="HDMI-0: nvidia-auto-select +1920+0 {rotation=right, ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}, DVI-D-0: nvidia-auto-select +0+420 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}"

# Consistent cursor size
xrandr --dpi 96
[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources
Xcursor.size: 64

# Disable mouse acceleration (because this desktop is not for soy gamers)
xinput --set-prop 'Kingsis Peripherals ZOWIE Gaming mouse' 'libinput Accel Profile Enabled' 0

# IBus fix
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus

# Enable IBus
ibus-daemon &

# WM
exec i3
