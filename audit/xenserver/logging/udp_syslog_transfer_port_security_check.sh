#!/bin/bash

TITLE="UDP Syslog Transfer Port (514) Security Check"
RESULT="PASS"
DETAILS=""

echo $(printf '%.0s-' {1..100}) >&2
echo "[*] Starting UDP syslog transfer port security check..." >&2
echo $(printf '%.0s-' {1..100}) >&2

# Check if port 514 is listening
echo "[*] Checking if UDP port 514 is open..." >&2
if netstat -unl | grep -q ":514 "; then
    RESULT="FAIL"
    DETAILS="UDP 514 port is active (syslog transfer port is open)"
    echo "[*] WARNING: UDP 514 port is active" >&2
else
    RESULT="PASS"
    DETAILS="UDP 514 port is not active (syslog transfer port is closed)"
    echo "[*] UDP 514 port is not active" >&2
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
