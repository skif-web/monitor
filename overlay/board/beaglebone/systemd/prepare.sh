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

mv /usr/zabbix/php-frontend/* ${TARGET_DIR}/var/www/


#########################################################
#
# mysql-zabbix restore
#
#########################################################

# permissions
# mysql -u root --execute "create database zabbix character set utf8 collate utf8_bin;"
mysql -u root --execute "create database zabbix;"
mysql -u root --execute "grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';"

# Try to find any dump
set -x
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