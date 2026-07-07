#!/usr/bin/env bash

#
# update_hmac.sh
#
# Update the stored hardware HMAC and rebuild initramfs.
#
set -euo pipefail

FLAG="/run/luks_hardware_mismatch"
EXPECTED_FILE="/root/luks/expected_hmac"
HMAC_BIN="/root/luks/hmac_check"

check_update_required()
{
    if [ ! -f "$FLAG" ]; then
        echo "No hardware update required."
        exit 0
    fi
}

check_dependencies()
{
    [ -x "$HMAC_BIN" ] || {
        echo "Missing hmac_check binary."
        exit 1
    }
}

update_expected_hmac()
{
    echo "[1] Updating hardware HMAC..."

    "$HMAC_BIN" --print-hmac > "$EXPECTED_FILE"

    chmod 600 "$EXPECTED_FILE"
}

rebuild_initramfs()
{
    echo "[2] Rebuilding initramfs..."

    update-initramfs -u -k "$(uname -r)"

    cp /boot/initrd.img-"$(uname -r)" \
       /boot/initramfs.gz \
       2>/dev/null || true
}

cleanup()
{
    rm -f "$FLAG"
}

main()
{
    check_update_required
    check_dependencies
    update_expected_hmac
    rebuild_initramfs
    cleanup
}

main "$@"