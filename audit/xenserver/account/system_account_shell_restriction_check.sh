#!/bin/bash

TITLE="System Account Shell Restriction Check"
RESULT="PASS"
DETAILS=""

echo "[*] Starting system account shell restriction check..." >&2

# Define system accounts that should have restricted shells
echo "[*] Defining system accounts that should have restricted shells..." >&2
RESTRICTED_ACCOUNTS=("daemon" "bin" "sys" "adm" "listen" "nobody" "nobody4" "noaccess" "diag" "operator" "games" "gopher")

# Define valid restricted shells
echo "[*] Defining valid restricted shells..." >&2
RESTRICTED_SHELLS=("/sbin/nologin" "/bin/false" "/usr/sbin/nologin")

# Initialize arrays for storing results
invalid_accounts=()

echo "[*] Checking system accounts..." >&2
while IFS=: read -r username password uid gid info home shell; do
    # Check if UID is system account (UID <= 100 or >= 60000)
    if [ "$uid" -le 100 ] || [ "$uid" -ge 60000 ]; then
        echo "[*] Checking account: $username (UID: $uid)" >&2

        # Check if account is in restricted list or has system UID
        for account in "${RESTRICTED_ACCOUNTS[@]}"; do
            if [ "$username" == "$account" ]; then
                # Check if shell is restricted
                shell_restricted=false
                for restricted_shell in "${RESTRICTED_SHELLS[@]}"; do
                    if [ "$shell" == "$restricted_shell" ]; then
                        shell_restricted=true
                        echo "[*] $username has restricted shell: $shell" >&2
                        break
                    fi
                done

                if ! $shell_restricted; then
                    echo "[*] WARNING: $username has unrestricted shell: $shell" >&2
                    invalid_accounts+=("$username ($shell)")
                fi
                break
            fi
        done
    fi
done </etc/passwd

# Determine result
if [ ${#invalid_accounts[@]} -eq 0 ]; then
    RESULT="PASS"
    DETAILS="All system accounts have properly restricted shells."
    echo "[*] All system accounts have properly restricted shells" >&2
else
    RESULT="FAIL"
    DETAILS="The following system accounts have unrestricted shells: ${invalid_accounts[*]}"
    echo "[*] Found system accounts with unrestricted shells" >&2
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
