#!/usr/bin/env bash

#
# install.sh
#
# Install the LUKS Hardware Binding Framework.
#

set -euo pipefail

check_root()
{
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root."
        exit 1
    fi
}

create_install_directory()
{
    mkdir -p /root/luks
    chmod 700 /root/luks
}

build_hmac_utility()
{
    echo "[1] Building HMAC utility..."

    make

    install -m 700 hmac_check /root/luks/hmac_check
}

install_files()
{
    echo "[2] Installing project files..."

    install -m 700 initramfs/hmac_getkey.sh \
        /root/luks/hmac_getkey.sh

    install -m 755 initramfs/luks-hmac \
        /etc/initramfs-tools/hooks/luks-hmac
}

generate_master_key()
{
    echo "[3] Generating master key..."

    if [ ! -f /root/luks/master.key ]; then
        dd if=/dev/urandom \
           of=/root/luks/master.key \
           bs=32 \
           count=1 \
           status=none
    fi

    chmod 600 /root/luks/master.key
}

generate_expected_hmac()
{
    echo "[4] Generating hardware HMAC..."

    /root/luks/hmac_check --print-hmac \
        > /root/luks/expected_hmac

    chmod 600 /root/luks/expected_hmac
}

install_systemd_service()
{
    echo "[5] Installing systemd service..."

    install -m 644 systemd/luks-update-hmac.service \
        /etc/systemd/system/luks-update-hmac.service
}

enable_systemd_service()
{
    echo "[6] Enabling systemd service..."
    systemctl daemon-reload
    systemctl enable luks-update-hmac.service
}

configure_crypttab()
{
    echo "[7] Configuring crypttab..."

    cat > /etc/crypttab << EOF
encrypted_root UUID=$(blkid -s UUID -o value /dev/mmcblk0p2) none luks,keyscript=/root/luks/hmac_getkey.sh
EOF
}

rebuild_initramfs()
{
    echo "[8] Updating initramfs..."

    update-initramfs -u -k "$(uname -r)"

    cp /boot/initrd.img-"$(uname -r)" \
       /boot/initramfs.gz \
       2>/dev/null || true
}


main()
{
    check_root
    create_install_directory
    build_hmac_utility
    install_files
    generate_master_key
    generate_expected_hmac
    install_systemd_service
    enable_systemd_service
    configure_crypttab
    rebuild_initramfs
}

main "$@"