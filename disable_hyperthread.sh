#!/bin/bash
num_cores=$(cat /proc/cpuinfo | grep processor | wc -l)
echo "number of cores="$num_cores

for i in {4..7..1}
do
	echo 0 > /sys/devices/system/cpu/cpu$i/online
	echo "Thread "$i" is disabled"
done
