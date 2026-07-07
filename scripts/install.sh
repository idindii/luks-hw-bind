#!/usr/bin/env bash

set -euo pipefail

check_root()
{
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root."
        exit 1
    fi
}

main()
{
    check_root
}

main "$@"