#!/bin/bash

cpu_temp=$(sensors | awk '/k10temp-pci-00c3/{getline; getline; print $2}' | sed 's/[+°C]//g' | awk '{print int($1 + 0.5)}')
amd_gpu_temp=$(sensors | awk '/amdgpu-pci-0600/{getline; getline; getline; getline; print $2}' | sed 's/[+°C]//g' | awk '{print int($1 + 0.5)}')
nvidia_gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)

max_temp=$cpu_temp
if [ $amd_gpu_temp -gt $max_temp ]; then
    max_temp=$amd_gpu_temp
fi
if [ $nvidia_gpu_temp -gt $max_temp ]; then
    max_temp=$nvidia_gpu_temp
fi

if [ $max_temp -gt 80 ]; then
cat << EOF
{ 
    "text":"$max_temp", 
    "tooltip":"CPU: $cpu_temp \n AMD", 
    "class":"critical"
}
EOF
else 
cat << EOF
{ "text":"$max_temp", "tooltip":"CPU: $cpu_temp°C\nGPU: $amd_gpu_temp°C (AMD)\nGPU: $nvidia_gpu_temp°C (NVIDIA)"}  
EOF
fi
