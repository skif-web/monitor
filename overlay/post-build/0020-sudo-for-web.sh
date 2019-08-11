#!/bin/bash

echo "www-data ALL=(ALL) NOPASSWD: /usr/bin/libWebInterface.sh" > ${TARGET_DIR}/etc/sudoers.d/web_interface