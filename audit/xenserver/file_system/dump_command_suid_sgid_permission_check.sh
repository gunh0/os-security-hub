#!/bin/bash

TITLE="Dump Command SUID/SGID Permission Check"
RESULT="PASS"
DETAILS=""

echo $(printf '%.0s-' {1..100}) >&2
echo "[*] Starting dump command SUID/SGID permission check..." >&2
echo $(printf '%.0s-' {1..100}) >&2

DUMP_PATH="/sbin/dump"

# Check if dump file exists
echo "[*] Checking if $DUMP_PATH exists..." >&2
if [ ! -f "$DUMP_PATH" ]; then
    RESULT="PASS"
    DETAILS="$DUMP_PATH file does not exist"
    echo "[*] Dump file not found" >&2
else
    # Get file permissions
    echo "[*] Checking file permissions..." >&2
    PERMISSION=$(ls -l $DUMP_PATH | awk '{print $1}')
    echo "[*] File permissions: $PERMISSION" >&2

    # Check for SUID/SGID bits
    if [[ $PERMISSION =~ ^-[rwx-]*s[rwx-]*$ ]] || [[ $PERMISSION =~ ^-[rwx-]*S[rwx-]*$ ]] ||
        [[ $PERMISSION =~ ^-[rwx-]*s.*s[rwx-]*$ ]] || [[ $PERMISSION =~ ^-[rwx-]*S.*S[rwx-]*$ ]]; then
        RESULT="FAIL"
        DETAILS="$DUMP_PATH has SUID/SGID bit set ($PERMISSION)"
        echo "[*] WARNING: SUID/SGID bit is set" >&2
    else
        RESULT="PASS"
        DETAILS="$DUMP_PATH does not have SUID/SGID bits set"
        echo "[*] SUID/SGID bits are not set" >&2
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
