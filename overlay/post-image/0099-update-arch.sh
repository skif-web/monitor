#!/bin/bash

##################################################
#
# description: create update-arch
# params: not avaible
#
##################################################

update_dir="${BINARIES_DIR}/update"

name=`grep BR2_TARGET_GENERIC_HOSTNAME .config|awk -F= '{print $2}'|tr -d \"`


rm -rf ${BINARIES_DIR}/update
rm -rf ${BINARIES_DIR}/${name}.tar.gz

mkdir -p ${BINARIES_DIR}/update

cp ${BINARIES_DIR}/*zImage ${update_dir}
cp ${TARGET_DIR}/usr/bin/update.sh ${update_dir}/
cd ${update_dir}/
sha256sum * > checksum.txt
cd ${BINARIES_DIR}/
bsdtar -a -cf ${BINARIES_DIR}/${name}.tar.gz update -C update
