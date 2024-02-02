#!/bin/bash

TITLE="Secure Log File Permission Check"
RESULT="PASS"
DETAILS=""

echo $(printf '%.0s-' {1..100}) >&2
echo "[*] Starting secure log file permission check..." >&2
echo $(printf '%.0s-' {1..100}) >&2

# Define secure log file
SECURE_LOG="/var/log/secure"

echo "[*] Checking if $SECURE_LOG exists..." >&2
if [ ! -f "$SECURE_LOG" ]; then
    RESULT="FAIL"
    DETAILS="$SECURE_LOG file does not exist"
    echo "[*] Secure log file not found" >&2
else
    # Get file owner and permissions
    echo "[*] Checking file ownership and permissions..." >&2
    OWNER=$(ls -l $SECURE_LOG | awk '{print $3}')
    PERMISSION=$(ls -l $SECURE_LOG | awk '{print $1}')
    OTHERS_PERM=$(stat -c %a "$SECURE_LOG" | cut -c3)

    echo "[*] File owner: $OWNER" >&2
    echo "[*] File permissions: $PERMISSION ($(stat -c %a $SECURE_LOG))" >&2

    if [ "$OWNER" != "root" ]; then
        RESULT="FAIL"
        DETAILS="$SECURE_LOG owner is not root (current: $OWNER)"
        echo "[*] WARNING: Incorrect file owner" >&2
    elif [[ "$OTHERS_PERM" =~ [2367] ]]; then
        RESULT="FAIL"
        DETAILS="$SECURE_LOG has write permissions for other users"
        echo "[*] WARNING: File has write permissions for others" >&2
    else
        RESULT="PASS"
        DETAILS="$SECURE_LOG has correct ownership (root) and appropriate permissions"
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
