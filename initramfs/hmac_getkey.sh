#!/bin/sh

#
# hmac_getkey.sh
#
# Initramfs keyscript used by cryptsetup.
# It authenticates the current hardware before
# returning the LUKS master key.
#

# Paths
HMAC_BIN="/root/luks/hmac_check"
EXPECTED_FILE="/root/luks/expected_hmac"
MASTER_KEY="/root/luks/master.key"
FLAG="/run/luks_hardware_mismatch"

# Verify required files exist
[ -x "$HMAC_BIN" ] || exit 1
[ -f "$EXPECTED_FILE" ] || exit 1
[ -f "$MASTER_KEY" ] || exit 1

# Generate the current hardware HMAC
CURRENT="$("$HMAC_BIN" --print-hmac 2>/dev/null)" || CURRENT=""

# Fall back to passphrase if HMAC generation fails
if [ -z "$CURRENT" ]; then
    echo "Cannot compute hardware HMAC." >&2
    /lib/cryptsetup/askpass "Enter LUKS passphrase: "
    exit 0
fi

# Read the expected HMAC
EXPECTED="$(cat "$EXPECTED_FILE")"

# Authenticate hardware
if [ "$CURRENT" = "$EXPECTED" ]; then
    cat "$MASTER_KEY"
else
    touch "$FLAG"
    /lib/cryptsetup/askpass "Hardware authentication failed. Enter LUKS passphrase: "
fi