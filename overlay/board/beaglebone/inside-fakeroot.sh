#!/bin/bash

#########################################################
#
# network settings
#
#########################################################

# disable systemd-networkd && systemd-resolved
# TODO

# rename default config 
mv ${TARGET_DIR}/etc/systemd/network/dhcp.network ${TARGET_DIR/}/etc/systemd/network/beaglebone.network

#########################################################
#
# make data.ing for second sdcard partition
#
#########################################################
dataImageFile="${BINARIES_DIR}/data.img"
dataImageMountDir="${BINARIES_DIR}/data"
dataImageFsType="ext4"
dataImageFsLabel="monitorData"

while mount|grep $dataImageMountDir > /dev/null
do
    sudo umount -l $dataImageFile
done

if [ -f $dataImageFile ]; then
    rm -rf $dataImageFile
fi

if [ -d $dataImageMountDir ]; then
    rm -rf $dataImageMountDir
fi
set -x
dd if=/dev/zero of=$dataImageFile bs=16M count=1
mkfs.$dataImageFsType -L $dataImageFsLabel $dataImageFile
mkdir -p $dataImageMountDir
sudo mount -t $dataImageFsType -o loop $dataImageFile $dataImageMountDir
sudo cp ${TARGET_DIR/}/etc/systemd/network/beaglebone.network  $dataImageMountDir/
sudo umount $dataImageMountDir

mkdir ${TARGET_DIR}/data/

#########################################################
#
# make fstab
#
#########################################################
fstabFile="${TARGET_DIR}/etc/fstab"
echo "" > $fstabFile

echo "LABEL=$dataImageFsLabel /data $dataImageFsType  defaults   0 1" >> $fstabFile