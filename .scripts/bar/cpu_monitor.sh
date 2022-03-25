#!/bin/bash
# Author: Chillpert

# Get CPU utilization (only number)
cpu_util=$(top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}' | cut -f1 -d".")

# Better version as the one above would always give low values even when compiling
# This version only works on systems where top -v will print procps-ng and not procps
#cpu_util=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
#cpu_util=${cpu_util:0:-1}

# Get CPU temperature (only number)
cpu_temp=$(sensors | grep Composite -m 1 | cut -c16- | cut -c1-2)

#echo $cpu_util

if (( ${cpu_util} >= 100 )); then cpu_util=99 cpu_util_formatted=99
fi

if (( ${cpu_util} <= 1 )); then cpu_util='01' cpu_util_formatted='01'
fi

if (( ${#cpu_util} == 1 )); then cpu_util_formatted='0'${cpu_util} ;
    else cpu_util_formatted=${cpu_util}
fi

echo "CPU: $cpu_temp°C/$cpu_util_formatted%"
