#!/bin/bash

TITLE="XSConsole File Permission Check"
RESULT="PASS"
DETAILS=""

echo "[*] Starting XSConsole file permission check..." >&2

# Define target file
XSCONSOLE_FILE="/usr/bin/xsconsole"

echo "[*] Checking if $XSCONSOLE_FILE exists..." >&2
if [ ! -f "$XSCONSOLE_FILE" ]; then
    RESULT="FAIL"
    DETAILS="$XSCONSOLE_FILE file does not exist"
    echo "[*] XSConsole file not found" >&2
else
    # Get file owner and permissions
    echo "[*] Checking file ownership and permissions..." >&2
    OWNER=$(ls -l $XSCONSOLE_FILE | awk '{print $3}')
    PERMISSION=$(ls -l $XSCONSOLE_FILE | awk '{print $1}')
    OTHERS_PERM=$(stat -c %a "$XSCONSOLE_FILE" | cut -c3)

    echo "[*] File owner: $OWNER" >&2
    echo "[*] File permissions: $PERMISSION ($(stat -c %a $XSCONSOLE_FILE))" >&2

    if [ "$OWNER" != "root" ]; then
        RESULT="FAIL"
        DETAILS="$XSCONSOLE_FILE owner is not root (current: $OWNER)"
        echo "[*] WARNING: Incorrect file owner" >&2
    # Check if others permission contains write bit (2,3,6,7)
    elif [[ "$OTHERS_PERM" =~ [2367] ]]; then
        RESULT="FAIL"
        DETAILS="$XSCONSOLE_FILE has write permissions for other users"
        echo "[*] WARNING: File has write permissions for others" >&2
    else
        RESULT="PASS"
        DETAILS="$XSCONSOLE_FILE has correct ownership (root) and appropriate permissions"
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