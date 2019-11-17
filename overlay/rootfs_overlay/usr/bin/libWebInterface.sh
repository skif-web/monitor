#!/bin/bash --login
source /etc/profile.d/monitorVariables.sh 
source $MY_LIB

f_get_uptime () {
    uptime |awk '{print $1,$2,$3,$4}'|tr -d ','
}

f_get_cpu_load () {
    mpstat
}

f_get_memory_load () {
    free -m
}

f_get_free_space () {
df -h |head -n 1
df -h |grep data
}

f_check_external () {
    external_exist=`df -h |grep '/data/pgsql'`
    if [ "x$external_exist" == "x" ];then
        echo "External drive status = fail!"
    else
        echo "External drive status = ok"
    fi
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

f_save_settings () {
    timezone=`echo $1`
    external=$2
    sed -i '/timezone=*/d' $SETTINGS && \
        sed -i '/external=*/d' $SETTINGS && \
        echo "timezone=$timezone" >> $SETTINGS && \
        echo "external=$external" >> $SETTINGS && \
        echo 'SAVED and APPLYED'
    if [ "x$3" != "x" ]; then
        echo -e "$3\n$4" |passwd root && \
        passwd=`grep root /etc/shadow` && \
        sed -i '/passwd=*/d' $SETTINGS && \
        echo passwd=$passwd >> $SETTINGS && \
        f_set_web_pass $3 && \
        echo "password updated"
    fi
}

f_save_network () {
    sed -i '/hostname=*/d' $SETTINGS
    echo "$1" >> $SETTINGS
    sed -i '/network=*/d' $SETTINGS && \
    sed -i '/ip=*/d' $SETTINGS && \
    sed -i '/netmask=*/d' $SETTINGS && \
    sed -i '/gateway=*/d' $SETTINGS && \
    sed -i '/dns1=*/d' $SETTINGS && \
    sed -i '/dns2=*/d' $SETTINGS && \
    echo $2 >> $SETTINGS
    echo $3 >> $SETTINGS
    echo $4 >> $SETTINGS
    echo $5 >> $SETTINGS
    echo $6 >> $SETTINGS
    echo $7 >> $SETTINGS
    
}

f_poweroff () {
    poweroff
}

f_reboot () {
    reboot
}

f_backup_settings () {
    # clear old backup
    file_list="$SETTINGS"
    bsdtar -a -cf $DATA/web/backup.tar.gz -C / $file_list && \
    echo "Success config backup" && \
    chown www-data:www-data /var/www/manage/uploads/* && \
    return 0
    echo "Error!Reboot and try later"
    }

f_backup_dump () {
    backup_filename="$DATA/web/last.sql"
    rm -rf $backup_filename
    /bin/pg_dump -h localhost --user zabbix zabbix > $backup_filename && \
    echo "Success DB backup" && return 0
    # if error
    echo "Error!Reboot and try later"
}

f_factory_reset () {
    set -x 2>&1
    rm -rf /data/zabbix_*conf 2>&1 && \
    rm -rf $SETTINGS 2>&1 && \
    f_clean_db && \
    rm -rf /data/pgsql/dir 2>&1 && \
    echo "Success reset, prease reboot" 2>&1  && \
    return 0
    echo "Error!Reboot and try later"
}

f_upload_config () {
    if [ -f $DATA/web/backup.tar.gz ]; then
        bsdtar  -xf  /data/web/backup.tar.gz  -C / && \
        echo "Success settings restore, please reboot" && \
        return 0
        echo "Error in config enable"
    else
        echo "Error in config enable"
    fi
}

f_upload_dump () {
    # set -x
    if [ -f $DATA/web/last.sql ]; then
        f_clean_db && \
        systemctl start postgresql && \
        f_create_db && \
        psql -U zabbix -d zabbix -h localhost -f $DATA/web/last.sql && 
        echo "Success settings restore, please reboot" && \
        systemctl stop zabbix-server && \
        return 0
        echo "Error in config enable"
    else
        echo "Error in config enable"
    fi
}

f_clean_upload () {
    rm -rf /var/www/manage/uploads/*
}

f_update () {
    set -x
    firmware="$DATA/web/firmware.tar.gz"
    if [ -f $firmware ];
    then
        return 0
        rm -rf $tmp/update 2>/dev/null
        mkdir -p $tmp/update
        bsdtar -ef $firmware -C /tmp/update
        # bash /tmp/update/update.sh && \
        echo "Update Success, please reboot" && \
        return 0
        return 1
    else
        echo "Error during update"
        return 1
    fi
}

command=$1
shift 
$command $@
