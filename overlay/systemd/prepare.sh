#!/bin/bash --login

#########################################################
#
# restore time zone 
#
#########################################################

# TODO восстановить часовой пояс из конфига
if [ -f $SETTINGS ]; then
    timezone=`grep 'timezone=' $SETTINGS|awk -F= '{print$NF}'`
    if [ "x$timezone" != "x" ]; then
        timedatectl set-timezone $timezone
    fi
fi
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
    echo "First boot" > /etc/issue
    echo "Wait for reboot" >> /etc/issue
    systemctl stop getty@tty2.service

    mkdir -p /storage
    cp -r /data/* /storage/
    rm -rf /storage/lost+found
    umount -f /data
    fdisk /dev/$dataVolumeRootDev > /dev/null >&1 << EOF
d
2
n
p



w
fi
EOF
    mkfs.ext4 -L monitorData $dataVolumeDev
    sync
    mount  $dataVolumeDev /data/
    mv /storage/* /data/
    reboot
else
    echo "Please wait until all services start" > /etc/issue
    mount  $dataVolumeDev /data/
fi

#########################################################
#
# generate and set root passwd
#
#########################################################
root_pass=`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 6 ; echo ''`
echo -e "$root_pass\n$root_pass" | (passwd root)
echo root path: $root_pass >> /etc/issue

#########################################################
#
# enable terminals
#
#########################################################

systemctl restart getty@tty1.service
systemctl start getty@tty2.service
systemctl start getty@tty3.service
systemctl start getty@tty4.service
systemctl start getty@tty5.service

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

if [ -f /data/wired.network ]; then
    cp /data/wired.network /etc/systemd/network/
fi

systemctl start systemd-networkd
systemctl start systemd-resolved

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
    sleep 0.1
done
# Try to find any dump
sqlDump=`ls -lt /data/fullDump\*.sql 2>/dev/null|head -n1|awk '{print $NF}'`

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
# systemd journald max logs size
#
#########################################################
 
 journalctl --vacuum-size=2M

#########################################################
#
# start zabbix services
#
#########################################################

systemctl restart zabbix-server
systemctl restart zabbix-agent

# TODO
# надо бы получение настроек сети в /etc/issue