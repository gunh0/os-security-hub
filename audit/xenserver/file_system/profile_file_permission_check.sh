#!/bin/bash

TITLE="Profile File Permission Check"
RESULT="PASS"
DETAILS=""

echo $(printf '%.0s-' {1..100})
echo "[*] Starting profile file permission check..." >&2
echo $(printf '%.0s-' {1..100})

# Define target file
PROFILE_FILE="/etc/profile"

echo "[*] Checking if $PROFILE_FILE exists..." >&2
if [ ! -f "$PROFILE_FILE" ]; then
    RESULT="FAIL"
    DETAILS="$PROFILE_FILE file does not exist"
    echo "[*] Profile file not found" >&2
else
    # Get file owner and permissions
    echo "[*] Checking file ownership and permissions..." >&2
    OWNER=$(ls -l $PROFILE_FILE | awk '{print $3}')
    PERMISSION=$(ls -l $PROFILE_FILE | awk '{print $1}')
    OTHERS_PERM=$(stat -c %a "$PROFILE_FILE" | cut -c3)

    echo "[*] File owner: $OWNER" >&2
    echo "[*] File permissions: $PERMISSION ($(stat -c %a $PROFILE_FILE))" >&2

    # Check if owner is root or bin
    if [[ ! "$OWNER" =~ ^(root|bin)$ ]]; then
        RESULT="FAIL"
        DETAILS="$PROFILE_FILE owner is not root or bin (current: $OWNER)"
        echo "[*] WARNING: Incorrect file owner" >&2
    # Check if others permission contains write bit (2,3,6,7)
    elif [[ "$OTHERS_PERM" =~ [2367] ]]; then
        RESULT="FAIL"
        DETAILS="$PROFILE_FILE has write permissions for other users"
        echo "[*] WARNING: File has write permissions for others" >&2
    else
        RESULT="PASS"
        DETAILS="$PROFILE_FILE has correct ownership (root/bin) and appropriate permissions"
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
