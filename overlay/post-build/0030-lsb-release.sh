#!/bin/bash

# /etc/monitor-release
name=`grep BR2_TARGET_GENERIC_HOSTNAME .config|awk -F= '{print $2}'|tr -d \"`
echo $name > ${TARGET_DIR}/etc/monitor-release
# TODO
# May be add /etc/os-release...may be...later...