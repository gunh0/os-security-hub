#!/bin/bash

TITLE="Authpriv Log Configuration Check"
RESULT="PASS"
DETAILS=""

echo $(printf '%.0s-' {1..100})
echo "[*] Starting authpriv log configuration check..." >&2
echo $(printf '%.0s-' {1..100})

# Define files to check
LOG_FILE="/var/log/secure"
RSYSLOG_CONF="/etc/rsyslog.conf"

echo "[*] Checking authpriv log configuration..." >&2

# First check rsyslog configuration
if grep -q "authpriv.*.*secure" "$RSYSLOG_CONF" || grep -q "authpriv.*/var/log/secure" "$RSYSLOG_CONF"; then
    echo "[*] Found correct authpriv logging configuration in rsyslog.conf" >&2

    # Then check if log file exists
    if [ -f "$LOG_FILE" ]; then
        RESULT="PASS"
        DETAILS="authpriv logging is properly configured to $LOG_FILE"
        echo "[*] Log file exists and logging is properly configured" >&2
    else
        RESULT="FAIL"
        DETAILS="authpriv logging is configured but $LOG_FILE does not exist"
        echo "[*] WARNING: Log file does not exist" >&2
    fi
else
    RESULT="FAIL"
    DETAILS="authpriv logging is not configured to $LOG_FILE in rsyslog.conf"
    echo "[*] WARNING: Logging configuration not found" >&2
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
