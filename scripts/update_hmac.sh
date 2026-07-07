#!/usr/bin/env bash

set -euo pipefail

LUKS_DIR="/root/luks"
FLAG="/run/luks_hardware_mismatch"
EXPECTED_FILE="$LUKS_DIR/expected_hmac"
HMAC_BIN="$LUKS_DIR/hmac_check"

check_root()
{
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root."
        exit 1
    fi
}

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

    mkdir -p "$LUKS_DIR"
    chmod 700 "$LUKS_DIR"
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

reboot_system()
{
    echo
    echo "Update completed."
    echo "Rebooting in 5 seconds..."

    sleep 5
    reboot
}

main()
{
    check_root
    check_update_required
    check_dependencies
    update_expected_hmac
    rebuild_initramfs
    cleanup
    reboot_system
}

main "$@"