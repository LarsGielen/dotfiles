#!/bin/bash

amd_gpu=$(cat /sys/class/hwmon/hwmon5/device/gpu_busy_percent)
nvidia_gpu=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)

max=$amd_gpu
if [ $nvidia_gpu -gt $max ]; then
    max=$nvidia_gpu
fi

cat << EOF
{ "text":"$max", "tooltip":"AMD: $amd_gpu\nNVIDIA: $nvidia_gpu" }  
EOF