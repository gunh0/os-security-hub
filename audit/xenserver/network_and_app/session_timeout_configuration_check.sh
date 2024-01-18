#!/bin/bash

TITLE="Session Timeout Configuration Check"
RESULT="PASS"
DETAILS=""

echo $(printf '%.0s-' {1..100}) >&2
echo "[*] Starting session timeout configuration check..." >&2
echo $(printf '%.0s-' {1..100}) >&2

# Initialize flags for timeout settings
PROFILE_TIMEOUT=false
XSCONSOLE_TIMEOUT=false

# Check /etc/profile timeout setting
echo "[*] Checking timeout configuration in /etc/profile..." >&2
if [ -f "/etc/profile" ]; then
    # Check for TMOUT setting
    if grep -q "^[[:space:]]*TMOUT=[0-9]" /etc/profile; then
        TMOUT_VALUE=$(grep "^[[:space:]]*TMOUT=[0-9]" /etc/profile | awk -F= '{print $2}' | head -1)
        echo "[*] Found TMOUT setting: $TMOUT_VALUE seconds" >&2
        if [ "$TMOUT_VALUE" -le 300 ]; then
            PROFILE_TIMEOUT=true
            echo "[*] TMOUT setting is appropriate" >&2
        else
            echo "[*] WARNING: TMOUT value is greater than recommended 300 seconds" >&2
        fi
    else
        echo "[*] WARNING: No TMOUT setting found in /etc/profile" >&2
    fi
else
    echo "[*] WARNING: /etc/profile file not found" >&2
fi

# Check xsconsole timeout setting
echo "[*] Checking timeout configuration in xsconsole..." >&2
if [ -f "/usr/bin/xsconsole" ]; then
    # Check for TIMEOUT setting in xsconsole
    if grep -q "TIMEOUT" /usr/bin/xsconsole; then
        XSCONSOLE_TIMEOUT=true
        echo "[*] Found timeout configuration in xsconsole" >&2
    else
        echo "[*] WARNING: No timeout setting found in xsconsole" >&2
    fi
else
    echo "[*] WARNING: xsconsole file not found" >&2
fi

# Determine final result
if $PROFILE_TIMEOUT && $XSCONSOLE_TIMEOUT; then
    RESULT="PASS"
    DETAILS="Timeout is properly configured in both /etc/profile and xsconsole"
    echo "[*] Timeout settings are properly configured in both locations" >&2
else
    RESULT="FAIL"
    DETAILS="Timeout is not properly configured: "
    if ! $PROFILE_TIMEOUT; then
        DETAILS+="/etc/profile timeout not set properly. "
    fi
    if ! $XSCONSOLE_TIMEOUT; then
        DETAILS+="xsconsole timeout not set properly."
    fi
    echo "[*] WARNING: Timeout settings are not properly configured" >&2
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
