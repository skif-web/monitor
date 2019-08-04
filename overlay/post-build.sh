#!/bin/bash
set -x

for file in ${BR2_EXTERNAL_alexeyOverlay_PATH}/post-build/*
do
    chmod +x $file
    $file
done