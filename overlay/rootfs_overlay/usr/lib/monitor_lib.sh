#!/bin/bash --login
source /etc/profile.d/monitorVariables.sh

f_clean_db () {
    systemctl stop zabbix-server 2>&1 && \
    psql --user postgres -h localhost  -c  "SELECT pg_terminate_backend (pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'zabbix';"
    psql --user postgres -h localhost  -c  "DROP DATABASE zabbix;"
    
    systemctl stop postgresql 2>&1 
    rm -rf $data/psql/dir/*
}

f_create_db () {
    psql --user postgres -h localhost -c "CREATE DATABASE zabbix ENCODING 'Unicode' TEMPLATE template0 OWNER zabbix;" && \
    psql --user postgres -h localhost -c "GRANT ALL PRIVILEGES ON DATABASE zabbix TO zabbix;"
}

f_dump_db () {
    pg_dump --user zabbix zabbix > /data/last.sql
}

f_set_web_pass () {
        web_hash=`echo -n "admin:manage:$1" | md5sum | cut -b -32` && \
        echo "admin:manage:$web_hash" > /etc/lighttpd/lighttpd-htdigest.user && \
        sed -i '/^web_passwd=*/d' $SETTINGS && \
        echo "web_passwd=admin:manage:$web_hash" >> $SETTINGS && \
        return 0
}