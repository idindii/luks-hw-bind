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
    echo "[*] Building HMAC utility..."

    make

    install -m 700 hmac_check /root/luks/hmac_check
}

install_files()
{
    echo "[*] Installing project files..."

    install -m 700 initramfs/hmac_getkey.sh \
        /root/luks/hmac_getkey.sh

    install -m 755 initramfs/luks-hmac \
        /etc/initramfs-tools/hooks/luks-hmac
}

generate_master_key()
{
    echo "[*] Generating master key..."

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
    echo "[*] Generating hardware HMAC..."

    /root/luks/hmac_check --print-hmac \
        > /root/luks/expected_hmac

    chmod 600 /root/luks/expected_hmac
}

main()
{
    check_root
    create_install_directory
    build_hmac_utility
    install_files
    generate_master_key
    generate_expected_hmac
}

main "$@"