#!/bin/bash
set -x

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
for service in $BR2_EXTERNAL_alexeyOverlay_PATH/board/beaglebone//systemd/*service
do
    serviceName=`echo $service|awk -F\/ '{print $NF}'`
    cp $service ${TARGET_DIR}/etc/systemd/system/
    cd ${TARGET_DIR}/etc/systemd/system/
    ln -sfr ${TARGET_DIR}/etc/systemd/system/$serviceName  ${TARGET_DIR}/etc/systemd/system/multi-user.target.wants/
done

#########################################################
#
# apache
#
#########################################################
# Add php
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
# Set index.php as default
rm ${TARGET_DIR}/usr/htdocs/index.html

sed -i -e 's/DirectoryIndex index.html/DirectoryIndex index.php/g' ${TARGET_DIR}/etc/apache2/httpd.conf




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
    mv ${TARGET_DIR}/usr/zabbix/php-frontend/* ${TARGET_DIR}/usr/htdocs/
    rm -rf ${TARGET_DIR}/usr/zabbix/php-frontend
fi

cat > ${TARGET_DIR}/usr/htdocs/conf/zabbix.conf.php <<EOF
<?php
// Zabbix GUI configuration file.
global $DB;

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
dd if=/dev/zero of=$dataImageFile bs=16M count=1
mkfs.$dataImageFsType -L $dataImageFsLabel $dataImageFile
mkdir -p $dataImageMountDir
sudo mount -t $dataImageFsType -o loop $dataImageFile $dataImageMountDir
sudo cp ${TARGET_DIR/}/etc/systemd/network/beaglebone.network  $dataImageMountDir/
sudo cp ${TARGET_DIR}/etc/zabbix_server.conf $dataImageMountDir/
sudo cp ${TARGET_DIR}/etc/zabbix_agentd.conf $dataImageMountDir/
sudo umount $dataImageMountDir

#########################################################
#
# make fstab
#
#########################################################
fstabFile="${TARGET_DIR}/etc/fstab"
echo "" > $fstabFile
echo "LABEL=$dataImageFsLabel /data $dataImageFsType  defaults   0 1" >> $fstabFile