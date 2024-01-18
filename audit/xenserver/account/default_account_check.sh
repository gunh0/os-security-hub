#!/bin/bash

TITLE="Default Account Check"
RESULT="PASS"
DETAILS=""

echo $(printf '%.0s-' {1..100}) >&2
echo "[*] Starting default account check..." >&2
echo $(printf '%.0s-' {1..100}) >&2

# Define unnecessary default accounts
echo "[*] Defining unnecessary default accounts..." >&2
DEFAULT_ACCOUNTS=("lp" "uucp" "nuucp")

# Initialize array for found accounts
found_accounts=()

# Check each default account
echo "[*] Checking for unnecessary default accounts..." >&2
for account in "${DEFAULT_ACCOUNTS[@]}"; do
    if grep -q "^$account:" /etc/passwd; then
        echo "[*] Found unnecessary account: $account" >&2
        found_accounts+=("$account")
    else
        echo "[*] Account not found: $account" >&2
    fi
done

# Determine result based on findings
if [ ${#found_accounts[@]} -eq 0 ]; then
    RESULT="PASS"
    DETAILS="No unnecessary default accounts (lp, uucp, nuucp) were found."
    echo "[*] No unnecessary default accounts found" >&2
else
    RESULT="FAIL"
    DETAILS="Found unnecessary default accounts: ${found_accounts[*]}"
    echo "[*] WARNING: Unnecessary default accounts detected" >&2
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
