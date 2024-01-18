#!/bin/bash

TITLE="Root Privilege Account Detection"
RESULT="PASS"
DETAILS=""

echo $(printf '%.0s-' {1..100}) >&2
echo "[*] Starting root privilege account detection..." >&2
echo $(printf '%.0s-' {1..100}) >&2

# System accounts that are allowed to have UID 0
echo "[*] Defining allowed system accounts..." >&2
SYSTEM_ACCOUNTS=("root" "daemon" "bin" "adm" "uucp" "nuucp" "lp" "hpdb")

# Get all accounts with UID 0
echo "[*] Scanning /etc/passwd for accounts with UID 0..." >&2
uid_0_accounts=$(awk -F: '$3 == 0 {print $1}' /etc/passwd)

echo "[*] Found accounts with UID 0: $uid_0_accounts" >&2

DETAILS="Accounts with UID 0: $uid_0_accounts. "

# Check each account with UID 0
echo "[*] Analyzing found accounts..." >&2
for account in $uid_0_accounts; do
    echo "[*] Checking account: $account" >&2
    is_system_account=false
    for sys_account in "${SYSTEM_ACCOUNTS[@]}"; do
        if [[ "$account" == "$sys_account" ]]; then
            is_system_account=true
            echo "[*] $account is an authorized system account" >&2
            break
        fi
    done

    if ! $is_system_account; then
        RESULT="FAIL"
        echo "[*] WARNING: Unauthorized root account detected: $account" >&2
        DETAILS="${DETAILS}Unauthorized account '$account' has root privileges (UID 0). "
    fi
done

if [ "$RESULT" = "PASS" ]; then
    echo "[*] No unauthorized root accounts found" >&2
    DETAILS="${DETAILS}No unauthorized accounts with root privileges found."
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
