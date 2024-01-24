#!/bin/bash

TITLE="XenStore Access Log Permission Check"
RESULT="PASS"
DETAILS=""

echo $(printf '%.0s-' {1..100}) >&2
echo "[*] Starting XenStore access log permission check..." >&2
echo $(printf '%.0s-' {1..100}) >&2

# Define XenStore access log file
XENSTORE_LOG="/var/log/xenstored-access.log"

echo "[*] Checking if $XENSTORE_LOG exists..." >&2
if [ ! -f "$XENSTORE_LOG" ]; then
    RESULT="FAIL"
    DETAILS="$XENSTORE_LOG file does not exist"
    echo "[*] XenStore access log file not found" >&2
else
    # Get file owner and permissions
    echo "[*] Checking file ownership and permissions..." >&2
    OWNER=$(ls -l $XENSTORE_LOG | awk '{print $3}')
    PERMISSION=$(ls -l $XENSTORE_LOG | awk '{print $1}')
    OTHERS_PERM=$(stat -c %a "$XENSTORE_LOG" | cut -c3)

    echo "[*] File owner: $OWNER" >&2
    echo "[*] File permissions: $PERMISSION ($(stat -c %a $XENSTORE_LOG))" >&2

    if [ "$OWNER" != "root" ]; then
        RESULT="FAIL"
        DETAILS="$XENSTORE_LOG owner is not root (current: $OWNER)"
        echo "[*] WARNING: Incorrect file owner" >&2
    elif [[ "$OTHERS_PERM" =~ [2367] ]]; then
        RESULT="FAIL"
        DETAILS="$XENSTORE_LOG has write permissions for other users"
        echo "[*] WARNING: File has write permissions for others" >&2
    else
        RESULT="PASS"
        DETAILS="$XENSTORE_LOG has correct ownership (root) and appropriate permissions"
        echo "[*] File ownership and permissions are correct" >&2
    fi
fi

# Output in JSON format
echo "[*] Generating final report..." >&2
cat <<EOF
{
    "title": "$TITLE",
    "result": "$RESULT",
    "details": "$DETAILS",
    "timestamp": "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
}
EOF
