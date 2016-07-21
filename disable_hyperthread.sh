#!/bin/bash
num_cores=$(cat /proc/cpuinfo | grep processor | wc -l)
echo "number of cores="$num_cores

for (( i=$((num_cores/2)); i < $num_cores ; i++ ))
do
	echo 0 > /sys/devices/system/cpu/cpu$i/online
	echo "Thread "$i" is disabled"
done
