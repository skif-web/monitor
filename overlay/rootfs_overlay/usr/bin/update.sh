#!/bin/bash
src="/tmp/update/update"

update_dir=`mktemp -d`
mkdir -p $update_dir
mount LABEL=system  $update_dir

cd  $src/
sha256sum -c checksum.txt && \
cp $src/bzImage $update_dir/ && \
sync && \
umount $update_dir