#!/bin/bash

#########################################################
#
# network settings
#
#########################################################

# rename default config 
if [ -f  ${TARGET_DIR}/etc/systemd/network/dhcp.network ]; then
    mv ${TARGET_DIR}/etc/systemd/network/dhcp.network ${TARGET_DIR}/etc/systemd/network/wired.network
fi

#########################################################
#
# install systemd files
#
#########################################################

cp $BR2_EXTERNAL_monitorOverlay_PATH/systemd/*sh ${TARGET_DIR}/usr/bin/
chmod +x ${TARGET_DIR}/usr/bin/*sh

# services
for service in $BR2_EXTERNAL_monitorOverlay_PATH//systemd/*service
do
    serviceName=`echo $service|awk -F\/ '{print $NF}'`
    cp $service ${TARGET_DIR}/etc/systemd/system/
    cd ${TARGET_DIR}/etc/systemd/system/
    ln -sfr ${TARGET_DIR}/etc/systemd/system/$serviceName  ${TARGET_DIR}/etc/systemd/system/multi-user.target.wants/
done

# timers
for timer in $BR2_EXTERNAL_monitorOverlay_PATH/systemd/*timer
do
    timerName=`echo $timer|awk -F\/ '{print $NF}'`
    cp $timer ${TARGET_DIR}/etc/systemd/system/
    cd ${TARGET_DIR}/etc/systemd/system/
    ln -sfr ${TARGET_DIR}/etc/systemd/system/$timerName  ${TARGET_DIR}/usr/lib/systemd/system/timers.target.wants/
done

#########################################################
#
# lighttpd - auth for /manage/
#
#########################################################

grep -q 'auth.backend.htdigest.userfile = "/etc/lighttpd/lighttpd-htdigest.user"' ${TARGET_DIR}/etc/lighttpd/lighttpd.conf
lighttpd_auth_status=$?
if [ $lighttpd_auth_status -gt 0 ]; then
	cat >> ${TARGET_DIR}/etc/lighttpd/lighttpd.conf <<EOF
server.modules += ( "mod_auth" )
server.modules += ( "mod_authn_file" )
auth.backend = "htdigest" 
auth.backend.htdigest.userfile = "/etc/lighttpd/lighttpd-htdigest.user" 
auth.debug = 0
auth.require = ( "/manage/" =>
                 (
                   "method"    => "digest",
                   "realm"     => "manage",
                   "require"   => "user=admin" 
                 )
                )
EOF
fi

#########################################################
#
# lighttpd - php
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


sed -i -e '/post_max_size =*/d'  ${TARGET_DIR}/etc/php.ini
sed -i -e '/max_execution_time =*/d'  ${TARGET_DIR}/etc/php.ini
sed -i -e '/max_input_time =*/d'  ${TARGET_DIR}/etc/php.ini
sed -i -e '/upload_max_filesize =*/d'  ${TARGET_DIR}/etc/php.ini

echo 'post_max_size = 1900M' >> ${TARGET_DIR}/etc/php.ini
echo 'max_execution_time = 300/g' >> ${TARGET_DIR}/etc/php.ini
echo 'max_input_time = 300/g' >> ${TARGET_DIR}/etc/php.ini
echo 'upload_max_filesize = 1800/g' >> ${TARGET_DIR}/etc/php.ini

#########################################################
#
# make zabbix default configs
#
#########################################################

# Set dbPassword for zabbix server
grep -q 'DBPassword=zabbix' ${TARGET_DIR}/etc/zabbix_server.conf || \
    sed -i -e '/DBPassword=/a\' -e 'DBPassword=zabbix' ${TARGET_DIR}/etc/zabbix_server.conf

#########################################################
#
# move  zabbix frontend to html  dir
#
#########################################################

if [ -d ${TARGET_DIR}/usr/zabbix/php-frontend ]; then
    mkdir -p ${TARGET_DIR}/var/www/zabbix/
    mv ${TARGET_DIR}/usr/zabbix/php-frontend/* ${TARGET_DIR}/var/www/zabbix/ && \
    rm -rf ${TARGET_DIR}/usr/zabbix/php-frontend
fi

cat > ${TARGET_DIR}/var/www/zabbix/conf/zabbix.conf.php <<EOF
<?php
// Zabbix GUI configuration file.
global \$DB;

\$DB['TYPE']     = 'POSTGRESQL';
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
# zabbix 
#
#########################################################

# allow access to RODOS-usb device
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="20a0", ATTR{idProduct}=="4173", MODE="0666"' > ${TARGET_DIR}/etc/udev/rules.d/zabbix-rodos.rules
# add zabbix-agent user parametr for rodos usb-termometr
sed -i -e '/UserParameter=rodos,*/d' ${TARGET_DIR}/etc/zabbix_agentd.conf
echo "UserParameter=rodos,rodos.sh" >> ${TARGET_DIR}/etc/zabbix_agentd.conf

#########################################################
#
# disable some services autorun (for debug)
#
#########################################################

# find ${TARGET_DIR}/etc ${TARGET_DIR}/usr/lib/systemd -iname multi-user.target.wants -type d|xargs -I {} find {} -iname zabbix-agent.service* -delete
# find ${TARGET_DIR}/etc ${TARGET_DIR}/usr/lib/systemd -iname multi-user.target.wants -type d|xargs -I {} find {} -iname zabbix-server.service* -delete
# find ${TARGET_DIR}/etc ${TARGET_DIR}/usr/lib/systemd -iname multi-user.target.wants -type d|xargs -I {} find {} -iname *postgre*.service* -delete

#########################################################
#
# journald 
#
#########################################################
# move to mem
sed -i 's/#Storage=[a-zA-Z]*/Storage=volatile/g' ${TARGET_DIR}/etc/systemd/journald.conf

#########################################################
#
# make fstab
#
#########################################################
fstabFile="${TARGET_DIR}/etc/fstab"
dataImageFsType="ext4"
dataImageFsLabel="monitorData"

echo "LABEL=$dataImageFsLabel /data $dataImageFsType  defaults   0 1" > $fstabFile
