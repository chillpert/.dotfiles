#!/bin/bash
# Author: Chillpert

# Get GPU utilization (only number)
gpu_util=$(nvidia-smi -q -d utilization | grep Gpu | cut -c45- | cut -c 1-2)

# Get GPU temperature (only number)
gpu_temp=$(nvidia-smi -q -d temperature | grep 'GPU Current Temp' | cut -c45- | cut -c 1-2)

if (( ${gpu_util} >= 100 )); then gpu_util=99
fi

if [[ ${gpu_util:1:1} == ' ' ]]; then gpu_util_formatted='0'${gpu_util:0:1} ;
    else gpu_util_formatted=${gpu_util}
fi

echo "GPU: $gpu_temp°C/$gpu_util_formatted%"
