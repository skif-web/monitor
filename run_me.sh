#!/bin/bash
clear
set -e
if [ "x$1" == "x" ]; then
	function="start"
else
	function=$1
fi


exclude_files='overlay utils ramdisk .gitignore LICENSE README.md run_me.sh .git buildroot-20*tar.gz \. '
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
buildroot_arch_name=`find . -maxdepth 1 -iname buildroot-20\*tar.gz `
patch_dir=$overlay_dir/buildroot_patches

echo patch_dir=$patch_dir
echo w_dir=$w_dir
echo overlay_dir=$overlay_dir
echo b_n=$buildroot_arch_name

find  $w_dir/.  -maxdepth 1  $find_cmd| xargs rm -rf

tar xpf $buildroot_arch_name 
buildroot_name=`basename $buildroot_arch_name .tar.gz`

cd $buildroot_name
defconfigs_array=()
for i in `find $overlay_dir/configs/ -type f -iname *_defconfig |awk -F\/ '{print $NF}'|sort`;do
	defconfigs_array+=("$i")
done

echo size=${#defconfigs_array[@]}

if [ ${#defconfigs_array[@]} -gt 0 ]; then
    index=0
    for defconfig in ${defconfigs_array[@]}; do
        echo [$index] $defconfig
        let index=${index}+1
    done

    if [ "x$2" != "x" ]; then
        answer=$2
    else
        read -p "Select defconfig, press A for abort. Default [0]" answer
        echo $answer
        if [ "x$answer" == "xA" ]
        then
            exit 1
        elif [ "x$answer" == "x" ]
        then
            answer=0
        fi
    fi
fi

if [ $answer -ge ${#defconfigs_array[@]} ]; then
    exit 22
fi

for patch_name in `find $patch_dir/ -iname *.diff|sort`
do
	echo $patch_name
 	patch -p1 < $patch_name
done

make BR2_EXTERNAL=$overlay_dir ${defconfigs_array[$answer]}
