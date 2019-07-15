#!/bin/bash
set -x

if [ -d  /var/mysql/zabbix ]; then
    # Second, remove dump's exept last 10
    find /data -iname fullDump\*.sql|sort -r| tail -n +10|xargs rm -rf

    DATADIR=/data
    # Get current size of zabbix DB
    size=`/bin/mysql -uroot -e "select table_schema,ROUND(sum(data_length + index_length) / 1024 / 1024) \
     from information_schema.tables WHERE table_schema = 'zabbix' GROUP BY table_schema;"|/bin/grep zabbix|/bin/awk '{print $NF}'`

    First, check free space on /data
    while true; do
        free_space=`df -k|grep '/data'|awk '{print $4}'`
        free_space=`expr $free_space / 1024`
        if [ $free_space -gt $size ];then
            break
        else
            find /data -iname fullDump\*.sql|sort -r| tail -n +1|xargs rm -rf
        fi
    done

    # Last, do dump
    touch /data/fullDump$(date +"%s").sql
    sync
    /bin/mysqldump zabbix > /data/fullDump$(date +"%s").sql
    sync
fi