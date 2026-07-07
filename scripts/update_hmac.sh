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

main()
{
    check_update_required
    check_dependencies
    update_expected_hmac
}

main "$@"