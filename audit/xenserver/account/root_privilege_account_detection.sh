#!/bin/bash

TITLE="Root Privilege Account Detection"
RESULT="PASS"
DETAILS=""

# System accounts that are allowed to have UID 0
SYSTEM_ACCOUNTS=("root" "daemon" "bin" "adm" "uucp" "nuucp" "lp" "hpdb")

# Get all accounts with UID 0
uid_0_accounts=$(awk -F: '$3 == 0 {print $1}' /etc/passwd)

DETAILS="Accounts with UID 0: $uid_0_accounts. "

# Check each account with UID 0
for account in $uid_0_accounts; do
    is_system_account=false
    for sys_account in "${SYSTEM_ACCOUNTS[@]}"; do
        if [[ "$account" == "$sys_account" ]]; then
            is_system_account=true
            break
        fi
    done

    if ! $is_system_account; then
        RESULT="FAIL"
        DETAILS="${DETAILS}Unauthorized account '$account' has root privileges (UID 0). "
    fi
done

if [ "$RESULT" = "PASS" ]; then
    DETAILS="${DETAILS}No unauthorized accounts with root privileges found."
fi

# Output in JSON format
cat <<EOF
{
   "title": "$TITLE",
   "result": "$RESULT",
   "details": "$DETAILS",
   "timestamp": "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
}
EOF
