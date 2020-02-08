#!/bin/bash

##################################################
#
# description: run scripts on post-image stage
# params: not avaible
#
##################################################

set -x

for file in ${BR2_EXTERNAL_monitorOverlay_PATH}/post-image/*
do
    chmod +x $file
    $file
done
