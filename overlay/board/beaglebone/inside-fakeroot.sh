#!/bin/bash

#########################################################
#
# network settings
#
#########################################################

# rename default config 
if [ -f  ${TARGET_DIR}/etc/systemd/network/dhcp.network ]; then
    mv ${TARGET_DIR}/etc/systemd/network/dhcp.network ${TARGET_DIR/}/etc/systemd/network/beaglebone.network
fi

#########################################################
#
# install systemd files
#
#########################################################

cp $BR2_EXTERNAL_alexeyOverlay_PATH/board/beaglebone/systemd/*sh ${TARGET_DIR}/usr/bin/
chmod +x ${TARGET_DIR}/usr/bin/*sh

# services
for service in $BR2_EXTERNAL_alexeyOverlay_PATH/board/beaglebone//systemd/*service
do
    serviceName=`echo $service|awk -F\/ '{print $NF}'`
    cp $service ${TARGET_DIR}/etc/systemd/system/
    cd ${TARGET_DIR}/etc/systemd/system/
    ln -sfr ${TARGET_DIR}/etc/systemd/system/$serviceName  ${TARGET_DIR}/etc/systemd/system/multi-user.target.wants/
done

# timers
for timer in $BR2_EXTERNAL_alexeyOverlay_PATH/board/beaglebone/systemd/*timer
do
    timerName=`echo $timer|awk -F\/ '{print $NF}'`
    cp $timer ${TARGET_DIR}/etc/systemd/system/
    cd ${TARGET_DIR}/etc/systemd/system/
    ln -sfr ${TARGET_DIR}/etc/systemd/system/$timerName  ${TARGET_DIR}/usr/lib/systemd/system/timers.target.wants/
done

#########################################################
#
# lighttpd
#
#########################################################

grep -q 'include "conf.d/fastcgi.conf' ${TARGET_DIR}/etc/lighttpd/lighttpd.conf
lighttpd_php_status=$?
echo @lighttpd_php_status@
if [ $lighttpd_php_status -gt 0 ]; then
	cat >> ${TARGET_DIR}/etc/lighttpd/lighttpd.conf <<EOF
include "conf.d/fastcgi.conf"	
EOF
        cat > ${TARGET_DIR}/etc/lighttpd/conf.d/fastcgi.conf <<EOF
server.modules += ( "mod_fastcgi" )
fastcgi.server  = ( ".php" => (( "socket" => "/var/run/php-fpm.sock", "allow-x-send-file" => "enable" )) )
EOF
fi

#########################################################
#
# php settings fix
#
#########################################################

sed -i -e 's/post_max_size = 8M/post_max_size = 16M/g' ${TARGET_DIR}/etc/php.ini
sed -i -e 's/max_execution_time = 30/max_execution_time = 300/g' ${TARGET_DIR}/etc/php.ini
sed -i -e 's/max_input_time = 60/max_input_time = 300/g' ${TARGET_DIR}/etc/php.ini

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
# move  zabbix frontend to html  dir
#
#########################################################

if [ -d ${TARGET_DIR}/usr/zabbix/php-frontend ]; then
    mv ${TARGET_DIR}/usr/zabbix/php-frontend/* ${TARGET_DIR}/var/www/
    rm -rf ${TARGET_DIR}/usr/zabbix/php-frontend
fi

cat > ${TARGET_DIR}/var/www/conf/zabbix.conf.php <<EOF
<?php
// Zabbix GUI configuration file.
global \$DB;

\$DB['TYPE']     = 'MYSQL';
\$DB['SERVER']   = 'localhost';
\$DB['PORT']     = '0';
\$DB['DATABASE'] = 'zabbix';
\$DB['USER']     = 'zabbix';
\$DB['PASSWORD'] = 'zabbix';

// Schema name. Used for IBM DB2 and PostgreSQL.
\$DB['SCHEMA'] = '';

\$ZBX_SERVER      = 'localhost';
\$ZBX_SERVER_PORT = '10051';
\$ZBX_SERVER_NAME = '';

\$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
EOF

#########################################################
#
# disable some services autorun
#
#########################################################

find ${TARGET_DIR}/etc ${TARGET_DIR}/usr/lib/systemd -iname multi-user.target.wants -type d|xargs -I {} find {} -iname systemd-resolved* -delete
find ${TARGET_DIR}/etc ${TARGET_DIR}/usr/lib/systemd -iname multi-user.target.wants -type d|xargs -I {} find {} -iname systemd-networkd.service* -delete
find ${TARGET_DIR}/etc ${TARGET_DIR}/usr/lib/systemd -iname multi-user.target.wants -type d|xargs -I {} find {} -iname zabbix-agent.service* -delete
find ${TARGET_DIR}/etc ${TARGET_DIR}/usr/lib/systemd -iname multi-user.target.wants -type d|xargs -I {} find {} -iname zabbix-server.service* -delete

#########################################################
#
# journald 
#
#########################################################
# move to mem
sed -i 's/#Storage=[a-zA-Z]*/Storage=volatile/g' ${TARGET_DIR}/etc/systemd/journald.conf

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
dd if=/dev/zero of=$dataImageFile bs=8M count=1
mkfs.$dataImageFsType -L $dataImageFsLabel $dataImageFile
mkdir -p $dataImageMountDir
sudo mount -t $dataImageFsType -o loop $dataImageFile $dataImageMountDir
sudo cp ${TARGET_DIR/}/etc/systemd/network/beaglebone.network  $dataImageMountDir/
sudo cp ${TARGET_DIR}/etc/zabbix_server.conf $dataImageMountDir/
sudo cp ${TARGET_DIR}/etc/zabbix_agentd.conf $dataImageMountDir/
sudo cp ${TARGET_DIR}/var/www/conf/zabbix.conf.php $dataImageMountDir/
chmod 0777 $dataImageMountDir/*
sudo umount $dataImageMountDir

#########################################################
#
# make fstab
#
#########################################################
fstabFile="${TARGET_DIR}/etc/fstab"
echo "" > $fstabFile
echo "LABEL=$dataImageFsLabel /data $dataImageFsType  defaults   0 1" >> $fstabFile