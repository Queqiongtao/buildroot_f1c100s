#!/bin/bash
set -e

MKIMAGE="${HOST_DIR}/bin/mkimage"
DTBS_SLOT_SIZE=524288
KERNEL_SLOT_SIZE=3932160

cp board/rhodesisland/epass/scripts/kernel.its "${BINARIES_DIR}"
cp board/rhodesisland/epass/scripts/dtbs.its "${BINARIES_DIR}"
cp board/rhodesisland/epass/logo/*.rgb565.gz "${BINARIES_DIR}"

cd "${BINARIES_DIR}"
rm -f dtbs.itb kernel.itb sysimage-nor.img
dd if=/dev/zero bs=64K count=8 status=none | tr '\000' '\377' > data.img
"${MKIMAGE}" -f dtbs.its dtbs.itb || exit 1
"${MKIMAGE}" -f kernel.its kernel.itb || exit 1

dtbs_size=$(wc -c < dtbs.itb)
kernel_size=$(wc -c < kernel.itb)
if [ "${dtbs_size}" -gt "${DTBS_SLOT_SIZE}" ]; then
    echo "dtbs.itb is too large: ${dtbs_size} > ${DTBS_SLOT_SIZE}" >&2
    exit 1
fi
if [ "${kernel_size}" -gt "${KERNEL_SLOT_SIZE}" ]; then
    echo "kernel.itb is too large: ${kernel_size} > ${KERNEL_SLOT_SIZE}" >&2
    exit 1
fi

echo ============ start building NOR image ============
cd "${OLDPWD}"
support/scripts/genimage.sh "${BINARIES_DIR}" \
    -c board/rhodesisland/epass/genimage-nor.cfg
