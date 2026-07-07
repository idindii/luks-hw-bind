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

main()
{
    check_root
    create_install_directory
    build_hmac_utility
}

main "$@"