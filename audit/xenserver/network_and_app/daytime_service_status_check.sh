#!/bin/bash

TITLE="Daytime (13) Service Status Check"
RESULT="PASS"
DETAILS=""

echo $(printf '%.0s-' {1..100}) >&2
echo "[*] Starting Daytime service status check..." >&2
echo $(printf '%.0s-' {1..100}) >&2

# Check if port 13 is in use
echo "[*] Checking if Daytime service port (13) is in use..." >&2
PORT_CHECK=$(netstat -tuln | grep ":13 ")

# Check for Daytime service process
echo "[*] Checking for Daytime service process..." >&2
PROCESS_CHECK=$(ps -ef | grep -i "daytime" | grep -v "grep" | grep -v $0)

if [ -n "$PORT_CHECK" ]; then
    RESULT="FAIL"
    DETAILS="Daytime service port (13) is in use"
    echo "[*] WARNING: Daytime service port is active" >&2
    echo "[*] Active port details:" >&2
    echo "$PORT_CHECK" >&2
elif [ -n "$PROCESS_CHECK" ]; then
    RESULT="FAIL"
    DETAILS="Daytime service process is running"
    echo "[*] WARNING: Daytime service process detected" >&2
    echo "[*] Process details:" >&2
    echo "$PROCESS_CHECK" >&2
else
    RESULT="PASS"
    DETAILS="Daytime service is not active (port 13 is unused and no process found)"
    echo "[*] Daytime service is not active" >&2
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
