#!/bin/bash

backup_dir="backup"

# Iterate over the backup files and restore each key
for backup_file in "${backup_dir}"/*.ini; do
    key=$(basename "$backup_file" | sed 's/-/\//g' | sed 's/\.ini$//')
    dconf load "/${key}/" < "${backup_file}"
    echo "Restored backup for /${key}/ from ${backup_file}"
done
