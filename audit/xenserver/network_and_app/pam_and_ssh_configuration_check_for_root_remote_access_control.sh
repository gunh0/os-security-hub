#!/bin/bash
TITLE="PAM and SSH Configuration Check for Root Remote Access Control"
RESULT="PASS"
DETAILS=""

echo $(printf '%.0s-' {1..100}) >&2
echo "[*] Starting root SSH and SFTP access control check..." >&2
echo $(printf '%.0s-' {1..100}) >&2

# Initialize array for findings
FINDINGS=()

# Check /etc/pam.d/login configuration
echo "[*] Checking /etc/pam.d/login configuration..." >&2
if [ -f "/etc/pam.d/login" ]; then
    PAM_CHECK=$(grep "pam_securetty.so" /etc/pam.d/login)
    if [ -z "$PAM_CHECK" ]; then
        FINDINGS+=("pam_securetty.so configuration not found in /etc/pam.d/login")
        echo "[!] WARNING: pam_securetty.so not configured in /etc/pam.d/login" >&2
    else
        echo "[*] Found pam_securetty.so configuration: $PAM_CHECK" >&2
    fi
else
    FINDINGS+=("/etc/pam.d/login file not found")
    echo "[!] WARNING: /etc/pam.d/login file not found" >&2
fi

# Check sshd_config configuration
echo "[*] Checking /etc/ssh/sshd_config configuration..." >&2
if [ -f "/etc/ssh/sshd_config" ]; then
    SSH_CHECK=$(grep "^PermitRootLogin" /etc/ssh/sshd_config)
    if [ -z "$SSH_CHECK" ]; then
        FINDINGS+=("PermitRootLogin setting not found in sshd_config")
        echo "[!] WARNING: PermitRootLogin setting not found in sshd_config" >&2
    else
        echo "[*] Found PermitRootLogin configuration: $SSH_CHECK" >&2
        if [[ "$SSH_CHECK" != *"no"* ]]; then
            FINDINGS+=("Root SSH login is not disabled (PermitRootLogin is not set to 'no')")
            echo "[!] WARNING: Root SSH login is not properly restricted" >&2
        fi
    fi
else
    FINDINGS+=("/etc/ssh/sshd_config file not found")
    echo "[!] WARNING: /etc/ssh/sshd_config file not found" >&2
fi

# Determine final result
if [ ${#FINDINGS[@]} -eq 0 ]; then
    RESULT="PASS"
    DETAILS="Root SSH/SFTP access is properly restricted"
else
    RESULT="FAIL"
    DETAILS="Found ${#FINDINGS[@]} security issues:"
    for finding in "${FINDINGS[@]}"; do
        DETAILS="$DETAILS\n- $finding"
    done
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
