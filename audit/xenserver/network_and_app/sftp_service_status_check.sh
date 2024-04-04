#!/bin/bash
TITLE="SFTP (115) Service Status Check"
RESULT="PASS"
DETAILS=""

echo $(printf '%.0s-' {1..100}) >&2
echo "[*] Starting SFTP service status check..." >&2
echo $(printf '%.0s-' {1..100}) >&2

# Check if port 115 is in use
echo "[*] Checking if SFTP service port (115) is in use..." >&2
PORT_CHECK=$(netstat -tuln | grep ":115 ")

# Check for SFTP service process
echo "[*] Checking for SFTP service process..." >&2
PROCESS_CHECK=$(ps -ef | grep -iw "sftp\|sftpd" | grep -v "sftp-server" | grep -v "grep" | grep -v $0)

if [ -n "$PORT_CHECK" ]; then
    RESULT="FAIL"
    DETAILS="SFTP service port (115) is in use"
    echo "[*] WARNING: SFTP service port is active" >&2
    echo "[*] Active port details:" >&2
    echo "$PORT_CHECK" >&2
elif [ -n "$PROCESS_CHECK" ]; then
    RESULT="FAIL"
    DETAILS="SFTP service process is running"
    echo "[*] WARNING: SFTP service process detected" >&2
    echo "[*] Process details:" >&2
    echo "$PROCESS_CHECK" >&2
else
    RESULT="PASS"
    DETAILS="SFTP service is not active (port 115 is unused and no process found)"
    echo "[*] SFTP service is not active" >&2
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
