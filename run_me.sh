#!/bin/bash

############################################################################
#
#   name: prepare buildroot for monitor-linux
#   desctiption: prepare buildroot for selected board
#   params:
#       first position param is optional. If exist, prepare for board number = $1
#       else show board list and need promt from user
#   results placed in $GIT_DIRECTORY/buildroot-{version}
#
############################################################################

clear

# set -e

# build in ramdisk
USE_RAMDISK=y
RAMDISK_SIZE=16G

if [ "x$1" != "x" ]; then
	board_num=$1
fi

exclude_files='overlay _config.yml ramdisk LICENSE .gitignore README.md run_me.sh .git buildroot-20*tar.gz \. '
find_cmd=""
for exclude in $exclude_files
do
	find_cmd="! -iname $exclude $find_cmd"
done 

w_dir=$(readlink -f "$0")
w_dir=$(dirname "$w_dir")
ram_dir="$w_dir/ramdisk"
overlay_dir="$w_dir/overlay"
cd $w_dir
buildroot_arch_name=`find $w_dir/ -maxdepth 1 -iname buildroot-20\*tar.gz `
buildroot_name=`basename $buildroot_arch_name .tar.gz`

patch_dir=$overlay_dir/buildroot_patches

# echo patch_dir=$patch_dir
# echo w_dir=$w_dir
# echo overlay_dir=$overlay_dir
# echo buildroot_arch_name=$buildroot_arch_name
# echo buildroot_name=$buildroot_name


mount | grep -q "$w_dir/$buildroot_name"
if [ $? -eq 0 ]; then
    sudo umount -l $w_dir/$buildroot_name
fi

find  $w_dir/.  -maxdepth 1  $find_cmd| xargs rm -rf

if [ "x$USE_RAMDISK" == "xy" ]; then
    mkdir -p $w_dir/$buildroot_name
    sudo mount -t tmpfs -o size=$RAMDISK_SIZE tmpfs $w_dir/$buildroot_name
    sudo chown $USER $w_dir/$buildroot_name
fi

cd $w_dir
tar xpf $buildroot_arch_name 

cd $buildroot_name
defconfigs_array=()
for i in `find $overlay_dir/configs/ -type f -iname *_defconfig |awk -F\/ '{print $NF}'|sort`;do
	defconfigs_array+=("$i")
done

# echo size=${#defconfigs_array[@]}

if [ ${#defconfigs_array[@]} -gt 0 ]; then
    index=0
    for defconfig in ${defconfigs_array[@]}; do
        echo [$index] $defconfig
        let index=${index}+1
    done
    if [ "x$board_num" == "x" ]; then
        read -p "Select defconfig, press A for abort. Default [0]" answer
    else
        answer=$board_num
    fi
    echo $answer
    if [ "x$answer" == "xA" ]
    then
        exit 1
    elif [ "x$answer" == "x" ]
    then
        answer=0
    fi
fi



for patch_name in `find $patch_dir/ -iname *.diff|sort`
do
	echo $patch_name
 	patch -p1 < $patch_name
done

make BR2_EXTERNAL=$overlay_dir ${defconfigs_array[$answer]}