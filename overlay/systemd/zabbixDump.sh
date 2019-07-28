#!/bin/bash
set -x
db_exist=`psql --user zabbix -lqt|awk '{print $1}'|grep zabbix`
if [ "x$db_exist" != "x" ]; then
    # First, remove dump's exept last 10
    find /data -iname fullDump\*.sql|sort -r| tail -n +10|xargs rm -rf

    DATADIR=/data
    # Get current size of zabbix DB
    size=`psql --user zabbix zabbix -c" SELECT pg_database_size('zabbix');"|head -n3|tail -n1|awk '{print $1}'`
    size=`expr $size / 1048576`
    # Second, check free space on /data
    while true; do
        free_space=`df -k|grep '/data'|awk '{print $4}'`
        free_space=`expr $free_space / 1024`
        if [ $free_space -gt $size ];then
            break
        else
            find /data -iname fullDump\*.sql|sort -r| tail -n +1|xargs rm -rf
        fi
    done

    pg_dump --user zabbix zabbix > /data/fullDump$(date +"%s").sql
    sync
fi