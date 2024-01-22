#!/bin/bash

TITLE="Ensure cramfs kernel module is not available"
RESULT="PASS"
DETAILS=""

echo $(printf '%.0s-' {1..100}) >&2
echo "[*] Starting cramfs kernel module check..." >&2
echo $(printf '%.0s-' {1..100}) >&2

# Initialize variables
MODULE_NAME="cramfs"
MODULE_TYPE="fs"
MODULE_PROCESSED_NAME=$(echo "$MODULE_NAME" | tr '-' '_')

# Check if module exists in filesystem
echo "[*] Checking if module exists in filesystem..." >&2
MODULE_EXISTS=false
if find /lib/modules/*/kernel/$MODULE_TYPE -type f -name "${MODULE_NAME}.ko*" 2>/dev/null | grep -q .; then
    MODULE_EXISTS=true
    echo "[*] Module found in filesystem" >&2
fi

# Check if module is built into kernel
echo "[*] Checking if module is built into kernel..." >&2
if [ "$MODULE_EXISTS" = "false" ] && grep -q "CONFIG_CRAMFS=y" "/boot/config-$(uname -r)" 2>/dev/null; then
    MODULE_EXISTS=true
    echo "[*] Module is built into kernel" >&2
fi

if [ "$MODULE_EXISTS" = "false" ]; then
    RESULT="NA"
    DETAILS="Module is not available on the system and not built into the kernel."
else
    # Check if module is loadable
    echo "[*] Checking if module is loadable..." >&2
    LOADABLE=$(modprobe -n -v "$MODULE_NAME")
    if echo "$LOADABLE" | grep -E '^[[:space:]]*install[[:space:]]+/bin/(true|false)' >/dev/null; then
        echo "[*] Module loading is disabled" >&2
    else
        echo "[*] WARNING: Module can be loaded" >&2
        RESULT="FAIL"
    fi

    # Check if module is currently loaded
    echo "[*] Checking if module is currently loaded..." >&2
    if lsmod | grep "$MODULE_NAME" >/dev/null 2>&1; then
        echo "[*] WARNING: Module is currently loaded" >&2
        RESULT="FAIL"
    else
        echo "[*] Module is not loaded" >&2
    fi

    # Check if module is blacklisted
    echo "[*] Checking if module is blacklisted..." >&2
    if ! modprobe --showconfig | grep -E "^[[:space:]]*blacklist[[:space:]]+$MODULE_PROCESSED_NAME" >/dev/null; then
        echo "[*] WARNING: Module is not blacklisted" >&2
        RESULT="FAIL"
    else
        echo "[*] Module is blacklisted" >&2
    fi

    # Set details based on result
    if [ "$RESULT" = "PASS" ]; then
        DETAILS="Module is properly disabled and blacklisted."
    else
        DETAILS="Module is available but not properly disabled or blacklisted."
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
