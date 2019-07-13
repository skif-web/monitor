#!/bin/bash

#########################################################
#
# enable terminals
#
#########################################################

systemctl start getty@tty1.service
systemctl start getty@tty2.service
systemctl start getty@tty3.service
systemctl start getty@tty4.service
systemctl start getty@tty5.service

#########################################################
#
# resize monitorData volume
#
#########################################################

dataVolumeDev=`blkid |grep 'LABEL="monitorData"'|awk '{print $1}'|tr -d :`
dataVolumeDevShortName=`echo $dataVolumeDev|awk -F/ '{print $NF}'`
dataVolumeSize=`df $dataVolumeDev|tail -n 1|awk '{print $2}'`
dataVolumeRootDev=`lsblk|grep -B2 $dataVolumeDevShortName|head -n 1|awk '{print $1}'`

if [ $dataVolumeSize -lt 524288 ]; then
    mkdir -p /storage
    cp -r /data/* /storage/
    rm -rf /storage/lost+found
    umount -f /data
    # fsck -f $dataVolumeDev
    fdisk /dev/$dataVolumeRootDev > /dev/null >&1 << EOF
d
2
n
p



w
fi
EOF
    mkfs.ext4 -L monitorData -E nodiscard $dataVolumeDev
    sync
    sleep 0.5
    mount  $dataVolumeDev /data/
    mv /storage/* /data/
else
    mount  $dataVolumeDev /data/
fi

#########################################################
#
# generate machine-id from MAC
#
#########################################################

MAC=$(ip a list eth0 | grep link/ether | awk '{print $2}' )
MACHINE_ID=$(echo $MAC | md5sum | awk '{print $1}' )
echo $MACHINE_ID > /etc/machine-id

#########################################################
#
# network settings restore
#
#########################################################

if [ -f /data/beaglebone.network ]; then
    cp /data/beaglebone.network /etc/systemd/network/
fi

#########################################################
#
# zabbix settings restore
#
#########################################################

# If any zabbix config exist on data-partition, then use them
if [ -f /data/zabbix_agentd.conf ]; then
    cp /data/zabbix_agentd.conf /etc/zabbix_agentd.conf
fi

if [ -f /data/zabbix_server.conf ]; then
    cp /data/zabbix_server.conf /etc/zabbix_server.conf
fi

if [ -f /data/zabbix.conf.php ]; then
    cp /data/zabbix.conf.php /var/www/conf/zabbix.conf.php
fi

#########################################################
#
# mysql-zabbix restore
#
#########################################################

# permissions
while true
do
    mysql -u root --execute "create database zabbix;" && \
    mysql -u root --execute "grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';" && \
    break
    sleep 0.5
done
# Try to find any dump
sqlDump=`ls -lt /data/zabbix_dump_*.sql 2>/dev/null|head -n1|awk '{print $NF}'`

if [ "x$sqlDump" != "x" ]; then
    # If dump exist, then restore it
    mysql -u root zabbix<$sqlDump
else
    # else use default files
    mysql -u root zabbix</usr/zabbix/mysql_schema/schema.sql
    mysql -u root zabbix</usr/zabbix/mysql_schema/images.sql
    mysql -u root zabbix</usr/zabbix/mysql_schema/data.sql
fi
# DEBUG
date > /date.txt

#########################################################
#
# php settings fix
#
#########################################################

sed -i -e 's/post_max_size = 8M/post_max_size = 16M/g' /etc/php.ini
sed -i -e 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php.ini
sed -i -e 's/max_input_time = 60/max_input_time = 300/g' /etc/php.ini

#########################################################
#
# systemd journald max logs size
#
#########################################################
 journalctl --vacuum-size=2M
