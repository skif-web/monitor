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
# mysql-zabbix restore
#
#########################################################

# permissions

# if exist dump, use dump
# else use default files

# DEBUG
date > /date.txt