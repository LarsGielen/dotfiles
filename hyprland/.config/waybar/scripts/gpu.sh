#!/bin/bash

amd_gpu=$(cat /sys/class/hwmon/hwmon5/device/gpu_busy_percent)
nvidia_gpu=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)

max=$amd_gpu
if [ $nvidia_gpu -gt $max ]; then
    max=$nvidia_gpu
fi

cat << EOF
{ "text":"$(printf "%2d" $max)", "tooltip":"AMD: $(printf "%2d" $amd_gpu)%\nNVIDIA: $(printf "%2d" $nvidia_gpu)%" }  
EOF