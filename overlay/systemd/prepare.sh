#!/bin/bash --login

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
# zabbix dirs
#
#########################################################

mkdir -p /run/zabbix
chown zabbix:zabbix /run/zabbix

#########################################################
#
# postgresql-zabbix restore
#
#########################################################

# permissions
psql --user postgres -c "CREATE USER zabbix WITH PASSWORD 'zabbix';" && \
    psql --user postgres -c "CREATE DATABASE zabbix ENCODING 'Unicode' TEMPLATE template0 OWNER zabbix;" && \
        psql --user postgres -c "GRANT ALL PRIVILEGES ON DATABASE zabbix TO zabbix;" 

# Try to find any dump
sqlDump=`ls -lt /data/fullDump*.sql 2>/dev/null|head -n1|awk '{print $NF}'`

# If dump exist, then restore it
# else use default files
if [ "x$sqlDump" != "x" ]; then
    psql -U zabbix -d zabbix -f $sqlDump
else
    psql -U zabbix -d zabbix -f /usr/zabbix/postgresql_schema/schema.sql
    # sleep 0.5
    psql -U zabbix -d zabbix -f /usr/zabbix/postgresql_schema/images.sql
    # sleep 0.5
    psql -U zabbix -d zabbix -f /usr/zabbix/postgresql_schema/data.sql
fi

#########################################################
#
# prepare issue
#
#########################################################

current_ip=`ifconfig eth0 |grep 'inet addr'| cut -d":" -f2|awk '{print $1}'`

echo "current ip $current_ip" > /etc/issue
echo "Ready to work" >> /etc/issue
systemctl restart getty@tty1.service
