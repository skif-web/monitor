#!/bin/bash --login
source /etc/profile.d/monitorVariables.sh 
source $MY_LIB

# set -x

#########################################################
#
# restore settings to profile
#
#########################################################

if [ ! -f $SETTINGS ]; then
    cp /etc/settingsDefault.txt $SETTINGS
fi

while read line
do
    echo $line >> /etc/profile.d/monitorSettings.sh
done< $SETTINGS
source /etc/profile.d/monitorSettings.sh

#########################################################
#
# restore root passwd
# 
#########################################################

passwd=`grep ^passwd= $SETTINGS|awk -F= '{print $2}'`
if [ "x$passwd" != "x" ]; then
    sed -i '/root:*/d' /etc/shadow
    echo $passwd >> /etc/shadow
fi
#########################################################
#
# restore web passwd
# 
#########################################################

if [ "x$web_passwd" == "x" ]; then
    f_set_web_pass admin
else
    echo $web_passwd > /etc/lighttpd/lighttpd-htdigest.user
fi

#########################################################
#
# hostname restore
# 
#########################################################

if [ "x$hostname" == "x" ]; then
    hostname="monitor.localnet"
fi
hostnamectl set-hostname $hostname

#########################################################
#
# restore time zone 
#
#########################################################

timedatectl set-timezone $timezone

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

start=$(cat /sys/block/$dataVolumeRootDev/$dataVolumeDevShortName/start)
end=$(($start+$(cat /sys/block/$dataVolumeRootDev/$dataVolumeDevShortName/size)))
newend=$(($(cat /sys/block/$dataVolumeRootDev/size)-8))

if [ "$newend" -gt "$end" ]
then
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
    # mkfs.ext4 -L monitorData $dataVolumeDev
    resize2fs $dataVolumeDev
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
set -x
echo '[Match]' > $NETWORK_CONF
echo 'Name=eth0' >> $NETWORK_CONF
echo '[Network]' >> $NETWORK_CONF
if [ "x$network" == 'xstatic' ]; then
    echo "Address=$ip/$netmask" >> $NETWORK_CONF
    echo "Gateway=$gateway" >>$NETWORK_CONF
    if [ "x$dns1" != "x" ]; then
        echo "DNS=$dns1 $dns2" >> $NETWORK_CONF
    fi
else
    echo 'DHCP=ipv4' >> $NETWORK_CONF
fi

#########################################################
#
# systemd journald max logs size
#
#########################################################
 
 journalctl --vacuum-size=2M

#########################################################
#
# external mount
#
#########################################################

clear
mkdir -p /data/pgsql
if [ "x$external" = "xy" ]; then
    external_exist=`blkid|awk '{print $2}'|grep "LABEL=\"external\""`
    if [ "x$external_exist" == "x" ]; then
        my_drive=`blkid|grep 'monitorData'| awk -F\: '{print $1}'|awk -F/ '{print $NF}'`
        all_drive=`lsblk -d|grep disk|awk '{print $1}'|sort`
        echo all_drive=$all_drive
        for drive in $all_drive
        do
            echo drive=$drive
           
            status=`echo $my_drive|grep $drive`
            if [ "x$status" == "x" ];then
                dd if=/dev/zero of=/dev/$drive count=1 bs=10M
                sync
                fdisk /dev/$drive > /dev/null >&1 << EOF
n
p



w
fi
EOF
        drive=`fdisk -l /dev/$drive|tail -n 1|awk '{print $1}'`
        mkfs.ext4 -L "external" ${drive}
        break
            fi
        done
    fi
    drive=`blkid|grep LABEL=\"external\"| awk -F: '{print $1}'`
    mount $drive /data/pgsql
    
fi
mkdir -p /data/pgsql/dir
chown postgres:postgres /data/pgsql/dir

#########################################################
#
# postgresql dir on hdd
#
#########################################################

mount -o bind /data/pgsql/dir /var/lib/pgsql

#########################################################
#
# web-interface upload dir
#
#########################################################

mkdir -p /var/www/manage/uploads
mkdir -p $DATA/web
mount -o bind $DATA/web /var/www/manage/uploads
chown www-data:www-data /var/www/manage/uploads