#!/bin/bash
TITLE="Crontab File Permission Check"
RESULT="PASS"
DETAILS=""

echo $(printf '%.0s-' {1..100}) >&2
echo "[*] Starting crontab file permission check..." >&2
echo $(printf '%.0s-' {1..100}) >&2

CRONTAB_FILE="/etc/crontab"

# Check if crontab file exists
echo "[*] Checking if $CRONTAB_FILE exists..." >&2
if [ ! -f "$CRONTAB_FILE" ]; then
    RESULT="FAIL"
    DETAILS="$CRONTAB_FILE file does not exist"
    echo "[!] Crontab file not found" >&2
else
    # Get file owner and permissions
    echo "[*] Checking file ownership and permissions..." >&2
    OWNER=$(ls -l $CRONTAB_FILE | awk '{print $3}')
    PERMISSION=$(ls -l $CRONTAB_FILE | awk '{print $1}')
    OTHERS_PERM=$(stat -c %a "$CRONTAB_FILE" | cut -c3)

    echo "[*] File owner: $OWNER" >&2
    echo "[*] File permissions: $PERMISSION ($(stat -c %a $CRONTAB_FILE))" >&2

    if [ "$OWNER" != "root" ]; then
        RESULT="FAIL"
        DETAILS="$CRONTAB_FILE owner is not root (current: $OWNER)"
        echo "[!] WARNING: Incorrect file owner" >&2
    elif [[ "$OTHERS_PERM" =~ [2367] ]]; then
        RESULT="FAIL"
        DETAILS="$CRONTAB_FILE has write permissions for other users"
        echo "[!] WARNING: File has write permissions for others" >&2
    else
        RESULT="PASS"
        DETAILS="$CRONTAB_FILE has correct ownership (root) and appropriate permissions"
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
