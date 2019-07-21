#!/bin/bash

#########################################################
#
# make data.img for second sdcard partition
#
#########################################################
ImageFile="${BINARIES_DIR}/sdcard.img"
ImageMountDir="${BINARIES_DIR}/sdcard"
kernelFile="${BINARIES_DIR}/bzImage"
mbrFile="${BINARIES_DIR}/syslinux/mbr.bin"

while mount|grep $ImageMountDir > /dev/null
do
    sudo umount -R -l $ImageMountDir/*
done

if [ -f $dataImageFsystemctl ]; then
    rm -rf $dataImageFile
fi

if [ -d $dataImageMountDir ]; then
    rm -rf $dataImageMountDir
fi
dd if=/dev/zero of=$ImageFile bs=700M count=1
loop_dev=`sudo losetup -fP $ImageFile --show`
echo $loop_dev
sudo fdisk $loop_dev > /dev/null 2>&1 << EOF
n
p
1

+70M
a
n
p
2


w
EOF
set -x
sync
sleep 0.5
sudo mkfs.vfat -n monitorboot ${loop_dev}p1
sync
sleep 0.5
sudo dd if=$mbrFile of=$loop_dev
sync
sleep 0.5
sudo output/build/syslinux-6.03/bios/linux/syslinux --install ${loop_dev}p1
echo $?
# sh
sync

sudo mkfs.ext4 -L monitorData ${loop_dev}p2
sync
sleep 0.5
fsck.ext4 -y -f  ${loop_dev}p2
sync
sleep 0.5
mkdir -p $ImageMountDir/sys
mkdir -p $ImageMountDir/data
sudo mount -o loop ${loop_dev}p1 $ImageMountDir/sys -o umask=000
sudo mount -t ext4 -o loop ${loop_dev}p2 ${ImageMountDir}/data 

cp ${BINARIES_DIR}/bzImage $ImageMountDir/sys/
cp ${BR2_EXTERNAL_alexeyOverlay_PATH}/board/x86_64/syslinux.cfg ${ImageMountDir}/sys/
sudo cp ${TARGET_DIR/}/etc/systemd/network/wired.network  ${ImageMountDir}/data/
sudo cp ${TARGET_DIR}/etc/zabbix_server.conf ${ImageMountDir}/data/
sudo cp ${TARGET_DIR}/etc/zabbix_agentd.conf ${ImageMountDir}/data/
sudo cp ${TARGET_DIR}/var/www/conf/zabbix.conf.php ${ImageMountDir}/data/
sudo chmod 0777 $ImageMountDir/data/*
sudo umount $ImageMountDir/data/
sudo umount $ImageMountDir/sys
sudo output/build/syslinux-6.03/bios/linux/syslinux --install ${loop_dev}p1

sudo losetup -d $loop_dev
sync
