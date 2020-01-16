#!/bin/bash
############################################################################
#
#   description: create version-files in /etc/
#   params: not avaible
#
############################################################################


# /etc/monitor-release
name=`grep BR2_TARGET_GENERIC_HOSTNAME .config|awk -F= '{print $2}'|tr -d \"`
echo $name > ${TARGET_DIR}/etc/monitor-release

DISTRIB_ID=`echo $name|awk -F\- '{print $1}'`
DISTRIB_RELEASE=`echo $name|awk -F\- '{print $2}'`

echo "DISTRIB_ID=$DISTRIB_ID" >${TARGET_DIR}/etc/lsb_release
echo "DISTRIB_RELEASE=$DISTRIB_RELEASE" >> ${TARGET_DIR}/etc/lsb_release
echo "DISTRIB_DESCRIPTION=$DISTRIB_ID $DISTRIB_RELEASE" >> ${TARGET_DIR}/etc/lsb_release