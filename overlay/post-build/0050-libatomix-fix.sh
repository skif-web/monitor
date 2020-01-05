#!/bin/bash

# libatomic crutch
if [ ! -f ${TARGET_DIR}/usr/lib/libatomic.so ]; then
    cp ${STAGING_DIR}/usr/lib/libatomic.* ${TARGET_DIR}/usr/lib/
fi