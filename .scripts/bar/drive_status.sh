#!/bin/bash
# Author: Chillpert

nvme0n1p1=$(df -h /dev/nvme0n1p1 | awk '{ print  $4 }' | tail -n 1)
nvme0n1p2=$(df -h /dev/nvme0n1p2 | awk '{ print  $4 }' | tail -n 1)
nvme0n1p3=$(df -h /dev/nvme0n1p3 | awk '{ print  $4 }' | tail -n 1)
sda1=$(df -h /dev/sda1 | awk '{ print  $4 }' | tail -n 1)

echo "  $nvme0n1p1 | $nvme0n1p2 | $nvme0n1p3 | $sda1"

