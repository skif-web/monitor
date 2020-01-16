#!/bin/bash

############################################################################
#
#   description: create sudoers for web-interface
#   params: not avaible
#
############################################################################

mkdir -p ${TARGET_DIR}/etc/sudoers.d
echo "www-data ALL=(ALL) NOPASSWD: /usr/bin/libWebInterface.sh" > ${TARGET_DIR}/etc/sudoers.d/web_interface