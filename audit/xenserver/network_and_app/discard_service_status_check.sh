#!/bin/bash

TITLE="Discard (9) Service Status Check"
RESULT="PASS"
DETAILS=""

echo $(printf '%.0s-' {1..100}) >&2
echo "[*] Starting Discard service status check..." >&2
echo $(printf '%.0s-' {1..100}) >&2

# Check if port 9 is in use
echo "[*] Checking if Discard service port (9) is in use..." >&2
PORT_CHECK=$(netstat -tuln | grep ":9 ")

# Check for Discard service process
echo "[*] Checking for Discard service process..." >&2
PROCESS_CHECK=$(ps -ef | grep -i "discard" | grep -v "grep" | grep -v $0)

if [ -n "$PORT_CHECK" ]; then
    RESULT="FAIL"
    DETAILS="Discard service port (9) is in use"
    echo "[*] WARNING: Discard service port is active" >&2
    echo "[*] Active port details:" >&2
    echo "$PORT_CHECK" >&2
elif [ -n "$PROCESS_CHECK" ]; then
    RESULT="FAIL"
    DETAILS="Discard service process is running"
    echo "[*] WARNING: Discard service process detected" >&2
    echo "[*] Process details:" >&2
    echo "$PROCESS_CHECK" >&2
else
    RESULT="PASS"
    DETAILS="Discard service is not active (port 9 is unused and no process found)"
    echo "[*] Discard service is not active" >&2
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
