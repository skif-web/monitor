#!/bin/bash
set -x

for file in ${BR2_EXTERNAL_monitorOverlay_PATH}/post-build/*
do
    chmod +x $file
    $file
done