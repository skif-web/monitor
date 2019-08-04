#!/bin/sh
set -x
DATADIR="${BINARIES_DIR}/data"
rm -rf $DATADIR
mkdir -p $DATADIR

cp ${TARGET_DIR/}/etc/systemd/network/wired.network  $DATADIR/
cp ${TARGET_DIR}/etc/zabbix_server.conf $DATADIR/
cp ${TARGET_DIR}/etc/zabbix_agentd.conf $DATADIR/
cp ${TARGET_DIR}/var/www/conf/zabbix.conf.php $DATADIR/

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
