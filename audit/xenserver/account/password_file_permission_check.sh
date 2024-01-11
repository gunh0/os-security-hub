#!/bin/bash

TITLE="Password File Permission Check"
RESULT="PASS"
DETAILS=""

echo "[*] Starting password file permission check..." >&2

# Check /etc/passwd file
PASSWD_FILE="/etc/passwd"

# Check if passwd file exists
echo "[*] Checking if $PASSWD_FILE exists..." >&2
if [ ! -f "$PASSWD_FILE" ]; then
    RESULT="FAIL"
    DETAILS="Password file $PASSWD_FILE does not exist"
    echo "[*] Password file not found" >&2
else
    echo "[*] Password file found. Checking ownership and permissions..." >&2

    # Get file owner and permissions
    OWNER=$(ls -l $PASSWD_FILE | awk '{print $3}')
    PERMISSION=$(ls -l $PASSWD_FILE | awk '{print $1}' | cut -c2-10 | tr -d '\n' | perl -ne 'printf("%o", oct("0".join("", map{$_=~/[rwx]/?"1":"0"}split(""))))')

    echo "[*] File owner: $OWNER" >&2
    echo "[*] File permissions: $PERMISSION" >&2

    # Check owner and permissions
    if [ "$OWNER" != "root" ]; then
        RESULT="FAIL"
        DETAILS="Password file owner is not root (current: $OWNER)"
        echo "[*] WARNING: Incorrect file owner" >&2
    elif [ "$PERMISSION" -ne 644 ]; then
        RESULT="FAIL"
        DETAILS="Password file permissions are incorrect (current: $PERMISSION, required: 644)"
        echo "[*] WARNING: Incorrect file permissions" >&2
    else
        RESULT="PASS"
        DETAILS="Password file has correct ownership (root) and permissions (644)"
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
