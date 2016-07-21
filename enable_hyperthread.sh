#!/bin/bash
num_cores=$(cat /proc/cpuinfo | grep processor | wc -l)
echo "number of cores="$num_cores

for i in {16..31..1}
do
	echo 1 > /sys/devices/system/cpu/cpu$i/online
	echo "Thread "$i" is enabled"
done
