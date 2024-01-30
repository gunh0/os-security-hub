#!/bin/bash

TITLE="CHARGEN (19) Service Status Check"
RESULT="PASS"
DETAILS=""

echo $(printf '%.0s-' {1..100}) >&2
echo "[*] Starting Character Generator service status check..." >&2
echo $(printf '%.0s-' {1..100}) >&2

# Check if port 19 is in use
echo "[*] Checking if CHARGEN service port (19) is in use..." >&2
PORT_CHECK=$(netstat -tuln | grep ":19 ")

# Check for CHARGEN service process
echo "[*] Checking for CHARGEN service process..." >&2
PROCESS_CHECK=$(ps -ef | grep -i "chargen" | grep -v "grep" | grep -v $0)

if [ -n "$PORT_CHECK" ]; then
    RESULT="FAIL"
    DETAILS="CHARGEN service port (19) is in use"
    echo "[*] WARNING: CHARGEN service port is active" >&2
    echo "[*] Active port details:" >&2
    echo "$PORT_CHECK" >&2
elif [ -n "$PROCESS_CHECK" ]; then
    RESULT="FAIL"
    DETAILS="CHARGEN service process is running"
    echo "[*] WARNING: CHARGEN service process detected" >&2
    echo "[*] Process details:" >&2
    echo "$PROCESS_CHECK" >&2
else
    RESULT="PASS"
    DETAILS="CHARGEN service is not active (port 19 is unused and no process found)"
    echo "[*] CHARGEN service is not active" >&2
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
