#!/usr/bin/env bash

set -euo pipefail

LUKS_DIR="/root/luks"
HMAC_BIN="$LUKS_DIR/hmac_check"
EXPECTED_FILE="$LUKS_DIR/expected_hmac"

check_root()
{
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root."
        exit 1
    fi
}

check_dependencies()
{
    [ -x "$HMAC_BIN" ] || {
        echo "Missing hmac_check binary."
        exit 1
    }
}

refresh_expected_hmac()
{
    echo "[1] Refreshing expected HMAC..."
    "$HMAC_BIN" --print-hmac > "$EXPECTED_FILE"
    chmod 600 "$EXPECTED_FILE"
}

rebuild_initramfs()
{
    echo "[2] Rebuilding initramfs..."
    update-initramfs -u -k "$(uname -r)"
    cp /boot/initrd.img-"$(uname -r)" /boot/initramfs.gz 2>/dev/null || true
}

main()
{
    check_root
    check_dependencies
    refresh_expected_hmac
    rebuild_initramfs
}

main "$@"