#!/bin/sh

BOARD_DIR="$(dirname $0)"

rm -rf ${BINARIES_DIR}/sys
mkdir -p ${BINARIES_DIR}/sys

cp ${BINARIES_DIR}/bzImage ${BINARIES_DIR}/sys
find ${BUILD_DIR}/grub2* -iname boot.img -exec cp {} $BINARIES_DIR \;
# grub config
mkdir -p ${BINARIES_DIR}/sys/boot/grub
cp ${BOARD_DIR}/grub.cfg ${BINARIES_DIR}/sys/boot/grub/


GENIMAGE_CFG="${BOARD_DIR}/genimage.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

rm -rf "${GENIMAGE_TMP}"

genimage \
    --rootpath "${BINARIES_DIR}" \
    --tmppath "${GENIMAGE_TMP}" \
    --inputpath "${BINARIES_DIR}" \
    --outputpath "${BINARIES_DIR}" \
    --config "${GENIMAGE_CFG}"
