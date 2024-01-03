#!/bin/bash

# Define the list of keys to backup
keys=(
    "org/gnome/desktop/interface"
    "org/gnome/desktop/background"
    "org/gnome/desktop/app-folders" # Custom app menu categories
    "org/gnome/desktop/input-sources"
    "org/gnome/desktop/a11y" # Show accessibility icon
    "org/gnome/desktop/peripherals/mouse" # Cursor speed
    "org/gnome/desktop/screensaver"
    "org/gnome/desktop/search-providers" # when searching using Super+D
    "org/gnome/desktop/wm/keybindings"
    "org/gnome/desktop/wm/preferences" # number of workspaces
    "org/gnome/mutter" # Workspace behaviors
    "org/gnome/terminal/legacy"
    "org/gnome/settings-daemon/plugins/media-keys" # More keybindings
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings" # Custom keybindings for launching terminals etc.
    "org/gnome/shell/app-switcher" # Only switch apps on current workspace
    "org/gnome/shell/extensions/auto-move-windows"
    "org/gnome/shell/extensions/just-perfection"
    "org/gnome/shell/extensions/workspaces-indicator-by-open-apps"
    "org/gnome/shell/extensions/quake-terminal"
    # "org/gnome/nautilus"
)

target_dir="backup"
mkdir -p ${target_dir}

# Iterate over the keys and backup each key in a separate file
for key in "${keys[@]}"; do
    out_filename="${target_dir}/$(echo "${key}" | sed 's/\//-/g').ini"

    # Backup key
    dconf dump "/${key}/" > "${out_filename}"

    echo "Backup created for /${key}/ in ${out_filename}"
done
