#!/bin/bash

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
    cp /data/zabbix.conf.php /usr/htdocs/conf/zabbix.conf.php

fi

#########################################################
#
# mysql-zabbix restore
#
#########################################################

# permissions
# mysql -u root --execute "create database zabbix character set utf8 collate utf8_bin;"
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