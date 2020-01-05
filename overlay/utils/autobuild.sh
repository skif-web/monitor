#!/bin/bash

############################################################################
#
#   name: autobuild for monitor-linux
#   desctiption: build all avaible config,don't need any params
#   results placed in $HOME/autobuild_result
#
############################################################################

# set -x

# Prepare dir's name
w_dir=$(readlink -f "$0")
w_dir=$(dirname "$w_dir")
git_dir=$(readlink -f "$w_dir/../../")
buildroot_dir=`find $git_dir -iname 'buildroot-*tar.gz'| rev | cut -d '.' -f3- | rev`
images_dir="$buildroot_dir/output/images"
output_dir="$HOME/autobuild_result"
log_file="$output_dir/autobuild_log"

# Clean result dir
rm -rf $output_dir
mkdir -p $output_dir

board_number=0

# This functions move ready images to result dir
# Also set proper files names
move_images () {
    # Ger release from board config
    release=`grep BR2_TARGET_GENERIC_HOSTNAME $buildroot_dir/.config|awk -F\" '{print $(NF-1)}'`
    echo release=$release
    echo board_name=$board_name
    set -x
    # Filenames and copy rules depends from board config
    case "$board_name" in 
        *)
            cp $images_dir/sdcard.img $output_dir/monitor_${board_name}_${release}_sdcard.img
        ;;
        x86-64)
            cp $images_dir/sdcard.img $output_dir/monitor_${board_name}_${release}_sdcard.img
            cp $images_dir/qemu.qcow2 $output_dir/monitor_${board_name}_${release}_system.qcow2
            cp $images_dir/external.qcow2 $output_dir/monitor_${board_name}_${release}_external.qcow2
        ;;
    esac

    # Also copy update
    cp $images_dir/$release.tar.gz $output_dir/monitor_${board_name}_update_to_$release.tar.gz
    sleep 1
    echo "$board_name build successful" >> $log_file
}

# If build not successful - log
print_error () {
    echo "$board_name build FAILED" >> $log_file
}


# While can build - build
while true
do
    bash $git_dir/run_me.sh $board_number
    if [ $? -gt 0 ]; then break; fi
    let board_number=${board_number}+1
    
    board_name=`grep BR2_DEFCONFIG $buildroot_dir/.config| awk -F\/ '{print $NF}'|awk -F_ '{print $2}'`

    echo board_number=$board_name
    echo board_number=$board_number
    cd $buildroot_dir && make 
    if [ $? -eq 0 ]
    then
        move_images
    else
        print_error
    fi
done