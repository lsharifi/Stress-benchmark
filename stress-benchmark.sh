#!/bin/bash 

timeout=30
cores=1
disk=1
mem=1
mega=`echo '2^20' | bc`
disk_size=$(df | grep /dev/sda1 | awk '{ print $2 }')
memory=$(cat /proc/meminfo | grep MemTotal |awk '{ print $2 }')
memory=$((memory / mega))
disk_size=$((disk_size / mega))
num_cores=$(cat /proc/cpuinfo | grep processor | wc -l)
echo "number of cores="$num_cores
echo "Total Memory Size in GB="$memory
echo "Total Disk Size in KB="$disk_size

for io_util in {1..100}
do
	while [ $mem -le $memory  ]; do
		while [ $disk -le $disk_size ]; do
			while [  $cores -le $num_cores ]; do
				for perc_utz in 20 40 60 80 100
				do
	        			mname="cpu-"$cores"-util-"$perc_utz"-memory-"$mem"-disk-"$disk

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
					sudo taskset -c $corelist stress -m $mem --vm-bytes 1024M -d $disk -i $io_util -c $cores & 
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
			disk=$((disk+50))
		done
	        mem=$((mem+1))
	done
done
