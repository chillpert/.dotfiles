#!/bin/bash
# Author: github.com/chillpert
# Print the next SpaceX launch
# Warning: Time zone is hardcoded (we don't do location tracking in this house!)

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
  echo $name: SpaceX does not have any upcoming launches. In other words: the world is ending!
else
  days=$((($time - $my_day) / 86400))
  
  # Precise time (hours and minutes)
  if (( $days == 0 )); then
    echo $name: $(TZ=Europe/Berlin date -d "@$time" '+%R')
  # Check validity
  elif (( $days < 0 )); then
    # This will probably never be the case anymore
    echo $name: tbd
  else
    echo $name in $days days
  fi
fi
