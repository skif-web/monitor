#!/bin/bash
source /etc/profile.d/monitorVariables.sh 

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
# restore locale
# 
#########################################################

localectl set-locale ru_RU.UTF-8

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
else
    echo "Please wait until all services start" > /dev/tty1
    mount  $dataVolumeDev /data/
fi

#########################################################
#
# generate and set root passwd
#
#########################################################
# root_pass=`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 6 ; echo ''`
# echo -e "$root_pass\n$root_pass" | (passwd root)
# echo root path: $root_pass >> /dev/tty1

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

#########################################################
#
# systemd journald max logs size
#
#########################################################
 
 journalctl --vacuum-size=2M