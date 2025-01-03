#!/bin/bash
TITLE="Service File Permission Check"
RESULT="PASS"
DETAILS=""

echo $(printf '%.0s-' {1..100}) >&2
echo "[*] Starting service file permission check..." >&2
echo $(printf '%.0s-' {1..100}) >&2

SERVICE_FILE="/etc/services" # Note: The correct path is /etc/services, not /etc/service

# Check if service file exists
echo "[*] Checking if $SERVICE_FILE exists..." >&2
if [ ! -f "$SERVICE_FILE" ]; then
    RESULT="FAIL"
    DETAILS="$SERVICE_FILE file does not exist"
    echo "[!] Service file not found" >&2
else
    # Get file owner and permissions
    echo "[*] Checking file ownership and permissions..." >&2
    OWNER=$(ls -l $SERVICE_FILE | awk '{print $3}')
    PERMISSION=$(ls -l $SERVICE_FILE | awk '{print $1}')
    OTHERS_PERM=$(stat -c %a "$SERVICE_FILE" | cut -c3)

    echo "[*] File owner: $OWNER" >&2
    echo "[*] File permissions: $PERMISSION ($(stat -c %a $SERVICE_FILE))" >&2

    # Check owner (root or bin)
    if [[ "$OWNER" != "root" && "$OWNER" != "bin" ]]; then
        RESULT="FAIL"
        DETAILS="$SERVICE_FILE owner is not root or bin (current: $OWNER)"
        echo "[!] WARNING: Incorrect file owner" >&2
    # Check write permissions for others
    elif [[ "$OTHERS_PERM" =~ [2367] ]]; then
        RESULT="FAIL"
        DETAILS="$SERVICE_FILE has write permissions for other users"
        echo "[!] WARNING: File has write permissions for others" >&2
    else
        RESULT="PASS"
        DETAILS="$SERVICE_FILE has correct ownership ($OWNER) and appropriate permissions"
        echo "[*] File ownership and permissions are correct" >&2
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
