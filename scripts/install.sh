#!/usr/bin/env bash
set -euo pipefail

LUKS_DIR="/root/luks"
LUKS_DEVICE="${LUKS_DEVICE:-/dev/mmcblk0p2}"

check_root()
{
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root."
        exit 1
    fi
}

create_install_directory()
{
    mkdir -p "$LUKS_DIR"
    chmod 700 "$LUKS_DIR"
}

build_hmac_utility()
{
    echo "[1] Building HMAC utility..."

    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

    cd "$PROJECT_ROOT"

    make

    install -m 700 ./hmac_check "$LUKS_DIR/hmac_check"
}

install_files()
{
    echo "[2] Installing project files..."

    install -m 700 \
        initramfs/hmac_getkey.sh \
        "$LUKS_DIR/hmac_getkey.sh"

    install -m 700 \
        scripts/update_hmac.sh \
        "$LUKS_DIR/update_hmac.sh"

    install -m 700 \
        scripts/refresh_binding.sh \
        "$LUKS_DIR/refresh_binding.sh"

    install -m 755 \
        initramfs/luks-hmac \
        /etc/initramfs-tools/hooks/luks-hmac
}

generate_master_key()
{
    echo "[3] Generating master key..."

    if [ ! -f "$LUKS_DIR/master.key" ]; then
        dd if=/dev/urandom \
           of="$LUKS_DIR/master.key" \
           bs=32 \
           count=1 \
           status=none
    fi

    chmod 600 "$LUKS_DIR/master.key"
}

generate_expected_hmac()
{
    echo "[4] Generating hardware HMAC..."

    "$LUKS_DIR/hmac_check" --print-hmac > "$LUKS_DIR/expected_hmac"
    chmod 600 "$LUKS_DIR/expected_hmac"
}

add_master_key_to_luks()
{
    echo "[5] Adding master key to LUKS..."

    local bound_key
    bound_key="$(mktemp)"

    "$LUKS_DIR/hmac_getkey.sh" > "$bound_key"

    chmod 600 "$bound_key"

    cryptsetup luksAddKey \
        "$LUKS_DEVICE" \
        "$bound_key"

    rm -f "$bound_key"
}

install_systemd_service()
{
    echo "[6] Installing systemd service..."
    install -m 644 systemd/luks-update-hmac.service \
        /etc/systemd/system/luks-update-hmac.service
}

enable_systemd_service()
{
    echo "[7] Enabling systemd service..."
    systemctl daemon-reload
    systemctl enable luks-update-hmac.service
}

configure_crypttab()
{
    echo "[8] Configuring crypttab..."

    local uuid
    local entry
    uuid="$(blkid -s UUID -o value "$LUKS_DEVICE")"
    entry="encrypted_root UUID=$uuid none luks,keyscript=$LUKS_DIR/hmac_getkey.sh"

    touch /etc/crypttab

    if grep -q '^encrypted_root ' /etc/crypttab; then
        sed -i "s|^encrypted_root .*|$entry|" /etc/crypttab
    else
        printf '%s\n' "$entry" >> /etc/crypttab
    fi
}

configure_bootloader()
{
    if [ -f /boot/config.txt ]; then
        if ! grep -q '^initramfs initramfs.gz followkernel$' /boot/config.txt; then
            echo "[9] Configuring bootloader..."
            echo "initramfs initramfs.gz followkernel" >> /boot/config.txt
        fi
    fi
}

rebuild_initramfs()
{
    echo "[10] Updating initramfs..."
    update-initramfs -u -k "$(uname -r)"
    cp /boot/initrd.img-"$(uname -r)" /boot/initramfs.gz 2>/dev/null || true
}

main()
{
    check_root
    create_install_directory
    build_hmac_utility
    install_files
    generate_master_key
    generate_expected_hmac
    add_master_key_to_luks
    install_systemd_service
    enable_systemd_service
    configure_crypttab
    configure_bootloader
    rebuild_initramfs
}

main "$@"