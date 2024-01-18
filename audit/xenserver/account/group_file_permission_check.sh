#!/bin/bash

TITLE="Group File Permission Check"
RESULT="PASS"
DETAILS=""

echo $(printf '%.0s-' {1..100}) >&2
echo "[*] Starting group file permission check..." >&2
echo $(printf '%.0s-' {1..100}) >&2

# Define target file
GROUP_FILE="/etc/group"

echo "[*] Checking if $GROUP_FILE exists..." >&2
if [ ! -f "$GROUP_FILE" ]; then
    RESULT="FAIL"
    DETAILS="$GROUP_FILE file does not exist"
    echo "[*] Group file not found" >&2
else
    echo "[*] Group file found. Checking ownership and permissions..." >&2

    # Get file owner and permissions
    OWNER=$(ls -l $GROUP_FILE | awk '{print $3}')
    PERMISSION=$(ls -l $GROUP_FILE | awk '{print $1}' | cut -c2-10 | tr -d '\n' | perl -ne 'printf("%o", oct("0".join("", map{$_=~/[rwx]/?"1":"0"}split(""))))')

    echo "[*] File owner: $OWNER" >&2
    echo "[*] File permissions: $PERMISSION" >&2

    # Check owner and permissions
    if [[ ! "$OWNER" =~ ^(root|bin)$ ]]; then
        RESULT="FAIL"
        DETAILS="$GROUP_FILE owner is not root or bin (current: $OWNER)"
        echo "[*] WARNING: Incorrect file owner" >&2
    elif [ "$PERMISSION" -ne 644 ]; then
        RESULT="FAIL"
        DETAILS="$GROUP_FILE permissions are incorrect (current: $PERMISSION, required: 644)"
        echo "[*] WARNING: Incorrect file permissions" >&2
    else
        RESULT="PASS"
        DETAILS="$GROUP_FILE has correct ownership ($OWNER) and permissions (644)"
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
