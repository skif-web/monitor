#!/bin/bash --login
source /etc/profile.d/monitorVariables.sh 
source $MY_LIB

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

# # permissions
zabbix_db_exist=`psql --user postgres -c "select datname from pg_database;"|grep zabbix`
if [ "x$zabbix_db_exist" == "x" ]; then

    user_zabbix_exist=`psql --user postgres -c "\du"|grep zabbix`
    if [ "x$user_zabbix_exist" == "x" ];then
        psql --user postgres -c "CREATE USER zabbix WITH PASSWORD 'zabbix';"
    fi
    
    f_create_db
    psql -U zabbix -d zabbix -f /usr/zabbix/postgresql_schema/schema.sql
    psql -U zabbix -d zabbix -f /usr/zabbix/postgresql_schema/images.sql
    psql -U zabbix -d zabbix -f /usr/zabbix/postgresql_schema/data.sql
fi

#########################################################
#
# prepare timezone list for web-gui
#
#########################################################

timedatectl list-timezones &> /var/www/manage/timezone.list

#########################################################
#
# prepare issue
#
#########################################################

current_ip=''
while [ "x$current_ip" == "x" ]; do
    current_ip=`ifconfig eth0 |grep 'inet addr'| cut -d":" -f2|awk '{print $1}'`
done

echo "current ip $current_ip" > /etc/issue
echo "Ready to work" >> /etc/issue
systemctl restart getty@tty1.service
