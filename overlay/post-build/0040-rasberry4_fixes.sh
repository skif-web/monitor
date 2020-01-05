#!/bin/bash

##################################################
#
# Rasberry pi 4 fixes
#
##################################################

grep -q 'my_rasberry4_defconfig' .config
if [ $? -ne 0 ]; then
    exit 0
fi

# custom kernel params
cat ${BR2_EXTERNAL_monitorOverlay_PATH}/board/rasberry4/cmdline.txt > ${BINARIES_DIR}/rpi-firmware/cmdline.txt

# disable splashscreen
# grep -q 'disable_splash=1' ${BINARIES_DIR}/rpi-firmware/config.txt
# if [ $? -ne 0 ]; then
#     echo 'disable_splash=1' >>  ${BINARIES_DIR}/rpi-firmware/config.txt
# fi
