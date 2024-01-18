#!/bin/bash

TITLE="Issue File Permission Check"
RESULT="PASS"
DETAILS=""

echo $(printf '%.0s-' {1..100}) >&2
echo "[*] Starting issue file permission check..." >&2
echo $(printf '%.0s-' {1..100}) >&2

# Define target file
ISSUE_FILE="/etc/issue"

echo "[*] Checking if $ISSUE_FILE exists..." >&2
if [ ! -f "$ISSUE_FILE" ]; then
    RESULT="FAIL"
    DETAILS="$ISSUE_FILE file does not exist"
    echo "[*] Issue file not found" >&2
else
    echo "[*] Issue file found. Checking ownership and permissions..." >&2

    # Get file owner and permissions
    OWNER=$(ls -l $ISSUE_FILE | awk '{print $3}')
    PERMISSION_STR=$(ls -l $ISSUE_FILE | awk '{print $1}')
    PERMISSION_OCT=$(stat -c %a $ISSUE_FILE)

    echo "[*] File owner: $OWNER" >&2
    echo "[*] File permissions: $PERMISSION_STR ($PERMISSION_OCT)" >&2

    # Check owner and permissions
    if [[ ! "$OWNER" =~ ^(root|bin)$ ]]; then
        RESULT="FAIL"
        DETAILS="$ISSUE_FILE owner is not root or bin (current: $OWNER)"
        echo "[*] WARNING: Incorrect file owner" >&2
    elif [[ "$PERMISSION_OCT" =~ [2367]$ ]]; then
        RESULT="FAIL"
        DETAILS="$ISSUE_FILE has write permissions for other users (current: $PERMISSION_STR, $PERMISSION_OCT)"
        echo "[*] WARNING: File has write permissions for others" >&2
    else
        RESULT="PASS"
        DETAILS="$ISSUE_FILE has correct ownership ($OWNER) and appropriate permissions ($PERMISSION_STR, $PERMISSION_OCT)"
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
