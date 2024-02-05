#!/bin/bash
TITLE="Time (37) Service Status Check"
RESULT="PASS"
DETAILS=""

echo $(printf '%.0s-' {1..100}) >&2
echo "[*] Starting Time service status check..." >&2
echo $(printf '%.0s-' {1..100}) >&2

# Check if port 37 is in use
echo "[*] Checking if Time service port (37) is in use..." >&2
PORT_CHECK=$(netstat -tuln | grep ":37 ")

# Check for Time service process with specific matching patterns
echo "[*] Checking for Time service process..." >&2
PROCESS_CHECK=$(ps -ef | grep -iw "time-service\|timeservice\|^time$" | grep -v "grep" | grep -v $0)

if [ -n "$PORT_CHECK" ]; then
    RESULT="FAIL"
    DETAILS="Time service port (37) is in use"
    echo "[*] WARNING: Time service port is active" >&2
    echo "[*] Active port details:" >&2
    echo "$PORT_CHECK" >&2
elif [ -n "$PROCESS_CHECK" ]; then
    RESULT="FAIL"
    DETAILS="Time service process is running"
    echo "[*] WARNING: Time service process detected" >&2
    echo "[*] Process details:" >&2
    echo "$PROCESS_CHECK" >&2
else
    RESULT="PASS"
    DETAILS="Time service is not active (port 37 is unused and no process found)"
    echo "[*] Time service is not active" >&2
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
