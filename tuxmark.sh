#!/bin/bash

# tuxmark
# benchmark utility which compiles the linux kernel to test a system's performance

VERSION="0.2.1"
DOWNLOAD_URL="https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.20.2.tar.xz"
KVERSION="linux-4.20.2"
DEPENDENCIES=("build-essential" "libncurses5" "bison" "flex" "libssl-dev" "libelf-dev")
TMPFS=1
NPROC=$(nproc)
ARCH="x86"

function evaluation () {
	score=$( echo "1222222/$1" | bc);
	MYVAR=$(grep "model name" /proc/cpuinfo | head -n 1)
	CPU_NAME=${MYVAR##"model name	: "}
	MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
	MEM_AVAIL=$(grep MemAvailable /proc/meminfo | awk '{print $2}')

	printf "\n***\n"
	printf "CPU: $CPU_NAME\n"
	printf "Threads: $NPROC\n"
	printf "MemTotal: $MEM_TOTAL\n"
	printf "MemAvailable: $MEM_AVAIL\n\n"
	printf "Compiling the linux kernel took %.3f seconds\n" "$1";
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

echo "v$VERSION";

cd `dirname $0`

mkdir -p src
mkdir -p build

for p in ${DEPENDENCIES[@]}; do
	if ! dpkg -l "$p" &> /dev/null; then
		printf "dependency $p missing. tuxmark depends on the following packages: \n"
		printf "%s\n" "${DEPENDENCIES[@]}"
		exit 11
	fi
done

if [ ! -f "src/$KVERSION.tar.xz" ]; then
	echo "need to download the linux kernel first."
	wget "$DOWNLOAD_URL" -q --show-progress -P src/
fi

if [ -n "$TMPFS" ]; then
	# tmpfs needs root
	if [[ $EUID -ne 0 ]]; then
		printf "tmpfs needs root\n" 
		exit 22
	fi

	mount -t tmpfs -o size=2048m tmpfs build || { printf "failed to mount tmpfs. Not enough RAM?\n"; exit 23;}	
fi

tar -xJf "src/$KVERSION.tar.xz" -C build
cp "conf/.config" "build/$KVERSION/"

cd "build/$KVERSION"

printf "compiling kernel. please wait.\n"
ts=$(date +%s%N)
#out=$(set -x; time yes "" | make -j $(nproc) 2>&1 /dev/null)
yes "" | make ARCH="$ARCH" -j $(nproc)

te=$((($(date +%s%N) - $ts)/1000000))
tseconds=$(echo "$te/1000" | bc -l)

cd ../../

cleanup;

evaluation $tseconds;

