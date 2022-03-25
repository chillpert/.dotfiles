#!/bin/bash
cd "/home/n30/.local/share/Steam/steamapps/compatdata/1245620/pfx/drive_c/users/steamuser/AppData/Roaming"

current_date=$(date)
date_converted=${current_date// /_}
destination="/home/$USER/Documents/EldenRingBackups/EldenRing_$date_converted"

mkdir -p $destination

cp -rf EldenRing $destination

echo "Saved EldenRing files"




