#!/bin/bash

##################################################
#
# description: add libatimic to target system from staging dir
# params: not avaible
#
##################################################


# libatomic crutch
if [ ! -f ${TARGET_DIR}/usr/lib/libatomic.so ]; then
    cp ${STAGING_DIR}/usr/lib/libatomic.* ${TARGET_DIR}/usr/lib/
fi