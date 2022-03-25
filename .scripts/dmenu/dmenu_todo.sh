#!/bin/sh
#
# Write/remove a task to do later.
#
# Select an existing entry to remove it from the file, or type a new entry to
# add it.
#

file="$HOME/.local/.dmenu-todo-list"
touch "$file"
height=$(wc -l "$file" | awk '{print $1}')
prompt="Tasks: "

cmd=$(dmenu -nf '#FFFFFF' -sb '#af87ff' -sf '#FFFFFF' -nb '#262626' -i -fn 'VL PGothic-11.5' -l 10 -w 0 -l "$height" -p "$prompt" "$@" < "$file")

while [ -n "$cmd" ]; do
 	if grep -q "^$cmd\$" "$file"; then
		grep -v "^$cmd\$" "$file" > "$file.$$"
		mv "$file.$$" "$file"
        height=$(( height - 1 ))
 	else
		echo "$cmd" >> "$file"
		height=$(( height + 1 ))
 	fi

	cmd=$(dmenu -nf '#FFFFFF' -sb '#af87ff' -sf '#FFFFFF' -nb '#262626' -i -fn 'VL PGothic-11.5' -l 10 -w 0 -l "$height" -p "$prompt" "$@" < "$file")


done

exit 0

