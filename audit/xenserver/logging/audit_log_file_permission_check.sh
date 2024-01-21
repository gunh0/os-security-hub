#!/bin/bash

TITLE="Audit Log File Permission Check"
RESULT="PASS"
DETAILS=""

echo $(printf '%.0s-' {1..100}) >&2
echo "[*] Starting audit log file permission check..." >&2
echo $(printf '%.0s-' {1..100}) >&2

# Define audit log file
AUDIT_LOG="/var/log/audit.log"

echo "[*] Checking if $AUDIT_LOG exists..." >&2
if [ ! -f "$AUDIT_LOG" ]; then
    RESULT="FAIL"
    DETAILS="$AUDIT_LOG file does not exist"
    echo "[*] Audit log file not found" >&2
else
    # Get file owner and permissions
    echo "[*] Checking file ownership and permissions..." >&2
    OWNER=$(ls -l $AUDIT_LOG | awk '{print $3}')
    PERMISSION=$(ls -l $AUDIT_LOG | awk '{print $1}')
    OTHERS_PERM=$(stat -c %a "$AUDIT_LOG" | cut -c3)

    echo "[*] File owner: $OWNER" >&2
    echo "[*] File permissions: $PERMISSION ($(stat -c %a $AUDIT_LOG))" >&2

    if [ "$OWNER" != "root" ]; then
        RESULT="FAIL"
        DETAILS="$AUDIT_LOG owner is not root (current: $OWNER)"
        echo "[*] WARNING: Incorrect file owner" >&2
    elif [[ "$OTHERS_PERM" =~ [2367] ]]; then
        RESULT="FAIL"
        DETAILS="$AUDIT_LOG has write permissions for other users"
        echo "[*] WARNING: File has write permissions for others" >&2
    else
        RESULT="PASS"
        DETAILS="$AUDIT_LOG has correct ownership (root) and appropriate permissions"
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
