#!/bin/bash
# Description: Check for unnecessary default accounts and their status
TITLE="Dangerous or Unnecessary Account Detection"
RESULT="PASS"
DETAILS=""
RISKY_ACCOUNTS=("lp" "uucp" "nuucp" "guest" "test" "xguest" "nobody" "messagebus")

# Function to check if account exists and get its status
check_account() {
    local account=$1
    if id "$account" >/dev/null 2>&1; then
        local shell=$(grep "^$account:" /etc/passwd | cut -d: -f7)
        local status=$(passwd -S "$account" 2>/dev/null)

        if echo "$status" | grep -q "P"; then
            DETAILS="${DETAILS}Account '$account' status: Active with password, Shell: $shell. "
            return 1
        elif echo "$status" | grep -q "L"; then
            DETAILS="${DETAILS}Account '$account' status: Locked, Shell: $shell. "
            return 0
        elif [[ "$shell" == "/sbin/nologin" ]] || [[ "$shell" == "/bin/false" ]]; then
            DETAILS="${DETAILS}Account '$account' has restricted shell: $shell. "
            return 0
        else
            DETAILS="${DETAILS}Account '$account' has unknown status with shell: $shell. "
            return 1
        fi
    else
        DETAILS="${DETAILS}Account '$account' does not exist. "
    fi
    return 0
}

# Check root account status
root_status=$(passwd -S root)
DETAILS="Root account status: $root_status. "

if ! echo "$root_status" | grep -q "P"; then
    RESULT="FAIL"
    DETAILS="${DETAILS}Root account is not properly configured - should be active with password. "
fi

# Check for risky default accounts
for account in "${RISKY_ACCOUNTS[@]}"; do
    if ! check_account "$account"; then
        RESULT="FAIL"
    fi
done

# Check for any suspicious accounts
suspicious_patterns="test|temp|tmp|guest|dummy"
suspicious_accounts=$(grep -E "$suspicious_patterns" /etc/passwd | cut -d: -f1)
if [ ! -z "$suspicious_accounts" ]; then
    RESULT="FAIL"
    DETAILS="${DETAILS}Found suspicious accounts: $suspicious_accounts. "
fi

# Add summary if passed
if [ "$RESULT" = "PASS" ]; then
    DETAILS="${DETAILS}Summary: Root account is properly configured. All checked risky accounts are either non-existent, locked, or have restricted shells. No suspicious accounts found."
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
