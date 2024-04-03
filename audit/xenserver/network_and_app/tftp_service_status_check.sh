#!/bin/bash
TITLE="TFTP (69) Service Status Check"
RESULT="PASS"
DETAILS=""

echo $(printf '%.0s-' {1..100}) >&2
echo "[*] Starting TFTP service status check..." >&2
echo $(printf '%.0s-' {1..100}) >&2

# Check if port 69 is in use
echo "[*] Checking if TFTP service port (69) is in use..." >&2
PORT_CHECK=$(netstat -tuln | grep ":69 ")

# Check for TFTP service process
echo "[*] Checking for TFTP service process..." >&2
PROCESS_CHECK=$(ps -ef | grep -iw "tftp\|tftpd" | grep -v "grep" | grep -v $0)

if [ -n "$PORT_CHECK" ]; then
    RESULT="FAIL"
    DETAILS="TFTP service port (69) is in use"
    echo "[*] WARNING: TFTP service port is active" >&2
    echo "[*] Active port details:" >&2
    echo "$PORT_CHECK" >&2
elif [ -n "$PROCESS_CHECK" ]; then
    RESULT="FAIL"
    DETAILS="TFTP service process is running"
    echo "[*] WARNING: TFTP service process detected" >&2
    echo "[*] Process details:" >&2
    echo "$PROCESS_CHECK" >&2
else
    RESULT="PASS"
    DETAILS="TFTP service is not active (port 69 is unused and no process found)"
    echo "[*] TFTP service is not active" >&2
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
