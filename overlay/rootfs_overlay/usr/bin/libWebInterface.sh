#!/bin/bash
source /etc/profile.d/monitorVariables.sh

f_get_uptime () {
    uptime |awk '{print $1,$2,$3,$4}'|tr -d ','
}

f_get_cpu_load () {
    mpstat
}

f_get_memory_load () {
    free -m
}

f_get_setting () {
    grep $1 $SETTINGS|awk -F= '{print $2}'
}

f_get_ip () {
    cat /proc/net/dev|tail -n +3|awk '{print $1}'|tr -d :|grep -ve "lo\|sit"|while read nic
    do
        ifconfig $nic
    done
}

f_save_setting () {
    timezone=`echo $1|tr -d '\r'`
    sed -i '/timezone=*/d' $SETTINGS
    echo "timezone=$timezone" >> $SETTINGS && \
        timedatectl set-timezone $timezone && \
        echo 'SAVED and APPLYED'
}

command=$1
shift 
$command $@
