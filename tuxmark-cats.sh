#!/bin/bash

# tuxmark
# benchmark which uses machinelearning to classify cat pictures

VERSION="0.2.1"
DEPENDENCIES=("python3-pip" "bc" "libxrender-dev" "libsm6" "libxext6")
#TMPFS=1
NPROC=$(nproc)

function evaluation () {
	score=$( echo "12222222/$1" | bc);
	catsps=$( echo "$catcount/$1" | bc -l);
	MYVAR=$(grep "model name" /proc/cpuinfo | head -n 1)
	CPU_NAME=${MYVAR##"model name	: "}
	MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
	MEM_AVAIL=$(grep MemAvailable /proc/meminfo | awk '{print $2}')

	printf "\n***\n"
	printf "CPU: $CPU_NAME\n"
	printf "Threads: $NPROC\n"
	printf "MemTotal: $MEM_TOTAL\n"
	printf "MemAvailable: $MEM_AVAIL\n\n"
	printf "Cats/s: %.1f\n" "$catsps"
	printf "Score: $score\n"
}

function cleanup () {
	if [ -n "$TMPFS" ]; then
		umount build
	fi
}

cat << "EOF"
      ___           ___           ___           ___           ___           ___           ___     
     /\  \         /\__\         |\__\         /\__\         /\  \         /\  \         /\__\    
     \:\  \       /:/  /         |:|  |       /::|  |       /::\  \       /::\  \       /:/  /    
      \:\  \     /:/  /          |:|  |      /:|:|  |      /:/\:\  \     /:/\:\  \     /:/__/     
      /::\  \   /:/  /  ___      |:|__|__   /:/|:|__|__   /::\~\:\  \   /::\~\:\  \   /::\__\____ 
     /:/\:\__\ /:/__/  /\__\ ____/::::\__\ /:/ |::::\__\ /:/\:\ \:\__\ /:/\:\ \:\__\ /:/\:::::\__\
    /:/  \/__/ \:\  \ /:/  / \::::/~~/~    \/__/~~/:/  / \/__\:\/:/  / \/_|::\/:/  / \/_|:|~~|~   
   /:/  /       \:\  /:/  /   ~~|:|~~|           /:/  /       \::/  /     |:|::/  /     |:|  |    
   \/__/         \:\/:/  /      |:|  |          /:/  /        /:/  /      |:|\/__/      |:|  |    
                  \::/  /       |:|  |         /:/  /        /:/  /       |:|  |        |:|  |    
                   \/__/         \|__|         \/__/         \/__/         \|__|         \|__| 
EOF

echo "cats per second benchmark v$VERSION";

cd `dirname $0`

for p in "${DEPENDENCIES[@]}"; do
	dpkg -l "$p" | grep "^ii" &> /dev/null || {
		printf "dependency $p missing. tuxmark depends on the following packages: \n";
		printf "%s\n" "${DEPENDENCIES[@]}";
		exit 11
	}
done

if [ -n "$TMPFS" ]; then
	# tmpfs needs root
	if [[ $EUID -ne 0 ]]; then
		printf "tmpfs needs root\n" 
		exit 22
	fi

	mount -t tmpfs -o size=2048m tmpfs build || { printf "failed to mount tmpfs. Not enough RAM?\n"; exit 23;}	
fi

printf "classifying cats\n"

catcount=0
ts=$(date +%s%N)
for f in var/testing_data/cats/cat.45*.jpg; do
	catcount=$((catcount+1))
	while (( (( $(jobs -p | wc -l) )) >= $NPROC )) ; do 
		sleep 0.05
	done
	# printf $f
	printf "."
	python utils/ml/predict.py $f 2>&1 > /dev/null &
done
te=$((($(date +%s%N) - $ts)/1000000))
tseconds=$(echo "$te/1000" | bc -l)

cleanup;

evaluation $tseconds;

