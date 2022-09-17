#!/usr/bin/env bash
# Author: github.com/chillpert

content=$(curl -sf 'https://api.spacexdata.com/v4/launches/upcoming')

name='ERROR'
first_run=true
counter=0

my_day=$(date '+%s')

# Iterate over JSON array over at https://api.spacexdata.com/v4/launches/upcoming
for it in $(jq -r '.[] | .date_unix' <<< "$content"); do
  if (( time > $it )) || [ "$first_run" = true ]; then
	# Never go for launches that were supposed to have already launched
	if (( $it >= my_day )); then
      time=$it
      first_run=false
      temp='.['$counter'] | .name'
      name=$(jq -r "$temp" <<< "$content")
	fi
  fi

  counter=$((counter+1))
done

if (( $counter == 0 )); then
  echo $name: Connection lost
else
  remaining_seconds=$(($time - $(date +%s)))
  remaining_hours=$(($remaining_seconds / 3600))
  remaining_days=$(($remaining_hours / 24))

  if (( $remaining_days < 1 )); then
    echo $name: in $remaining_hours hours
  else
    echo $name: in $remaining_days days
  fi
fi
