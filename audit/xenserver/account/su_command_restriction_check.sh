#!/bin/bash

TITLE="SU Command Restriction Check"
RESULT="PASS"
DETAILS=""

echo "[*] Starting SU command restriction check..." >&2

# Check if /etc/pam.d/su file exists
echo "[*] Checking /etc/pam.d/su file..." >&2
if [ ! -f "/etc/pam.d/su" ]; then
    RESULT="FAIL"
    DETAILS="/etc/pam.d/su file does not exist"
    echo "[*] /etc/pam.d/su file not found" >&2
else
    # Check for wheel group configuration in pam.d/su
    echo "[*] Checking for wheel group configuration..." >&2
    wheel_config=$(grep -v "^#" /etc/pam.d/su | grep "auth.*required.*pam_wheel.so.*use_uid")

    if [ -z "$wheel_config" ]; then
        RESULT="FAIL"
        DETAILS="auth required pam_wheel.so use_uid is not properly configured in /etc/pam.d/su"
        echo "[*] Wheel group configuration not found or commented out" >&2
    else
        # Check wheel group in /etc/group
        echo "[*] Checking wheel group members..." >&2
        wheel_group=$(grep "^wheel:" /etc/group)

        if [ -z "$wheel_group" ]; then
            RESULT="FAIL"
            DETAILS="Wheel group does not exist in /etc/group"
            echo "[*] Wheel group not found in /etc/group" >&2
        else
            # Get number of users in wheel group
            wheel_users=$(echo $wheel_group | cut -d: -f4 | tr ',' ' ' | wc -w)
            echo "[*] Found $wheel_users users in wheel group" >&2

            if [ $wheel_users -eq 0 ]; then
                RESULT="FAIL"
                DETAILS="Wheel group exists but has no members"
            else
                RESULT="PASS"
                DETAILS="SU command is properly restricted. PAM wheel configuration is enabled and wheel group has $wheel_users members"
            fi
        fi
    fi
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
