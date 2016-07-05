#!/bin/bash 

timeout=30
cores=1

num_cores=$(cat /proc/cpuinfo | grep processor | wc -l)
echo "number of cores="$num_cores


while [  $cores -le $num_cores ]; do
	for perc_utz in 20 40 60 80 100
	do
        mname="cpu-"$cores"-util-"$perc_utz

	echo "++++" running monitor $mname "++++"
	
	#
	# start monitors
	#
	counter=1
	corelist=0
	for (( c=1 ; c < $cores ; c++ ))
	do
		echo $corelist
		corelist=$corelist","$c
	done
	echo "Core Set ="$corelist
	#
	# start stress 30 seconds
	#
	sudo taskset -c $corelist stress -c $cores & 
	sleep 1
	#
	# cpu limit
	#
	ARRAY1=' ' read -a IDs <<< $(pidof stress) 
	for element in ${IDs[@]}
	do
		sudo cpulimit -p $element -l $perc_utz &
	done
	#
	# wait timeout
	#
	sleep $timeout
	#
	# stop monitors
	#
	sudo killall stress
	sleep 2
	done
	cores=$((cores+1))
done
