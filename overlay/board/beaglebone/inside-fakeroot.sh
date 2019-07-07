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
# make fstab
#
#########################################################
fstabFile="${TARGET_DIR}/etc/fstab"
echo "" > $fstabFile
echo "LABEL=$dataImageFsLabel /data $dataImageFsType  defaults   0 1" >> $fstabFile

#########################################################
#
# install systemd files
#
#########################################################

cp $BR2_EXTERNAL_alexeyOverlay_PATH/board/beaglebone/systemd/*sh ${TARGET_DIR}/usr/bin/
chmod +x ${TARGET_DIR}/usr/bin/*sh
for service in $BR2_EXTERNAL_alexeyOverlay_PATH/board/beaglebone//systemd/*service
do
    serviceName=`echo $service|awk -F\/ '{print $NF}'`
    cp $service ${TARGET_DIR}/etc/systemd/system/
    cd ${TARGET_DIR}/etc/systemd/system/
    ln -sfr ${TARGET_DIR}/etc/systemd/system/$serviceName  ${TARGET_DIR}/etc/systemd/system/multi-user.target.wants/
done

#########################################################
#
# add apache php support
#
#########################################################

set -x
grep -q 'SetHandler application/x-httpd-php' ${TARGET_DIR}/etc/apache2/httpd.conf
php_apache_status=$?
echo @$php_apache_status@
if [ $php_apache_status -gt 0 ]; then
    cat >> ${TARGET_DIR}/etc/apache2/httpd.conf <<EOF
<FilesMatch ".+\.ph(p[3457]?|t|tml)$">
    SetHandler application/x-httpd-php
</FilesMatch>
EOF
fi


#########################################################
#
# make zabbix default configs
#
#########################################################

# Set dbPassword for zabbix server
zabbix_password_status=grep -q 'DBPassword=zabbix' ${TARGET_DIR}/etc/zabbix_server.conf || \
    sed -i -e '/DBPassword=/a\' -e 'DBPassword=zabbix' ${TARGET_DIR}/etc/zabbix_server.conf

#########################################################
#
# make data.img for second sdcard partition
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

if [ -f $dataImageFsystemctl start prepare.serviceile ]; then
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
sudo cp ${TARGET_DIR}/etc/zabbix_server.conf $dataImageMountDir/
sudo cp ${TARGET_DIR}/etc/zabbix_agent.conf $dataImageMountDir/
sudo umount $dataImageMountDir

mkdir ${TARGET_DIR}/data/