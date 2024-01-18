#!/bin/bash

TITLE="UMASK Default Configuration Check"
RESULT="PASS"
DETAILS=""

echo $(printf '%.0s-' {1..100}) >&2
echo "[*] Starting UMASK configuration check..." >&2
echo $(printf '%.0s-' {1..100}) >&2

# Define valid UMASK values
echo "[*] Defining valid UMASK values..." >&2
VALID_UMASKS=("022" "027")

# Initialize variables
CURRENT_UMASK=$(umask)
PROFILE_UMASK=""

echo "[*] Current system UMASK: $CURRENT_UMASK" >&2

# Check /etc/profile for UMASK setting
echo "[*] Checking UMASK configuration in /etc/profile..." >&2
if [ -f "/etc/profile" ]; then
    PROFILE_UMASK=$(grep -i "^umask" /etc/profile | awk '{print $2}' | head -1)
    if [ -n "$PROFILE_UMASK" ]; then
        echo "[*] Found UMASK setting in /etc/profile: $PROFILE_UMASK" >&2
    else
        echo "[*] No UMASK setting found in /etc/profile" >&2
    fi
else
    echo "[*] WARNING: /etc/profile file not found" >&2
fi

# Validate UMASK values
umask_valid=false
for valid_umask in "${VALID_UMASKS[@]}"; do
    if [ "$CURRENT_UMASK" == "$valid_umask" ]; then
        umask_valid=true
        break
    fi
done

# Determine result
if [ "$umask_valid" = false ]; then
    RESULT="FAIL"
    DETAILS="Current system UMASK ($CURRENT_UMASK) is not set to a secure value (022 or 027)"
    echo "[*] Current UMASK value is not secure" >&2
elif [ -z "$PROFILE_UMASK" ]; then
    RESULT="FAIL"
    DETAILS="UMASK is not configured in /etc/profile"
    echo "[*] UMASK not found in /etc/profile" >&2
else
    RESULT="PASS"
    DETAILS="Current system UMASK ($CURRENT_UMASK) is secure and properly configured in /etc/profile"
    echo "[*] UMASK configuration is correct" >&2
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
