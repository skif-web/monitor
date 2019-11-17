#!/bin/sh

DATADIR="${BINARIES_DIR}/data"
rm -rf $DATADIR
mkdir -p $DATADIR

cp ${TARGET_DIR}/etc/settingsDefault.txt $DATADIR/

echo overlay=${BR2_EXTERNAL_alexeyOverlay_PATH}

GENIMAGE_CFG="${BR2_EXTERNAL_alexeyOverlay_PATH}/genDataImage.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

rm -rf "${GENIMAGE_TMP}"

genimage \
    --rootpath "${BINARIES_DIR}" \
    --tmppath "${GENIMAGE_TMP}" \
    --inputpath "${BINARIES_DIR}" \
    --outputpath "${BINARIES_DIR}" \
    --config "${GENIMAGE_CFG}"

grep -q 'BR2_x86_64=y' .config &&  qemu-img create -f qcow2 ${BINARIES_DIR}/external.qcow2 10G