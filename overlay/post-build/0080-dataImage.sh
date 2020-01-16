#!/bin/sh

##################################################
#
# description: create data-volume images
# params: not avaible
#
##################################################

DATADIR="${BINARIES_DIR}/data"
rm -rf $DATADIR
mkdir -p $DATADIR

echo overlay=${BR2_EXTERNAL_monitorOverlay_PATH}

GENIMAGE_CFG="${BR2_EXTERNAL_monitorOverlay_PATH}/genDataImage.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

rm -rf "${GENIMAGE_TMP}"

genimage \
    --rootpath "${BINARIES_DIR}" \
    --tmppath "${GENIMAGE_TMP}" \
    --inputpath "${BINARIES_DIR}" \
    --outputpath "${BINARIES_DIR}" \
    --config "${GENIMAGE_CFG}"

# For QEMU x86_64 create second volume
grep -q 'BR2_x86_64=y' .config &&  qemu-img create -f qcow2 ${BINARIES_DIR}/external.qcow2 10G