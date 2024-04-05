#!/bin/bash
TITLE="Home Directory and Configuration Files Permission Check"
RESULT="PASS"
DETAILS=""
VULN_ITEMS=()
CHECKED_ITEMS=()

echo $(printf '%.0s-' {1..100}) >&2
echo "[*] Starting home directory and configuration files permission check..." >&2
echo $(printf '%.0s-' {1..100}) >&2

# List of configuration files to check
CONFIG_FILES=".profile .kshrc .cshrc .bashrc .bash_profile .login .exrc .netrc .dtprofile .Xdefaults"

echo "[*] Checking user accounts from /etc/passwd..." >&2
USERS=$(awk -F: '$3 >= 1000 && $3 != 65534 && $6 != "/" {print $1 ":" $6}' /etc/passwd)

# Initialize counters
VULN_COUNT=0
CHECK_COUNT=0

# Check each user
while IFS=: read -r username homedir; do
    echo "[*] Checking user: $username" >&2
    echo "[*] Home directory: $homedir" >&2

    # Check if home directory exists
    if [ ! -d "$homedir" ]; then
        VULN_ITEMS+=("Home directory $homedir does not exist")
        continue
    fi

    # Check home directory permissions
    ((CHECK_COUNT++))
    dir_perms=$(stat -c "%a" "$homedir")
    echo "[*] Checking home directory permission: $dir_perms" >&2
    CHECKED_ITEMS+=("Checked $username's home directory ($homedir): permission ${dir_perms}")
    if [ $((0$dir_perms & 02)) -ne 0 ]; then
        ((VULN_COUNT++))
        echo "[!] WARNING: Directory has write permission for others" >&2
        VULN_ITEMS+=("Directory $homedir has write permission for others (${dir_perms})")
    fi

    # Check configuration files permissions
    for file in $CONFIG_FILES; do
        if [ -f "$homedir/$file" ]; then
            ((CHECK_COUNT++))
            file_perms=$(stat -c "%a" "$homedir/$file")
            echo "[*] Checking $file permission: $file_perms" >&2
            CHECKED_ITEMS+=("Checked $username's $file: permission ${file_perms}")
            if [ $((0$file_perms & 02)) -ne 0 ]; then
                ((VULN_COUNT++))
                echo "[!] WARNING: File has write permission for others" >&2
                VULN_ITEMS+=("File $homedir/$file has write permission for others (${file_perms})")
            fi
        fi
    done
    echo >&2
done <<<"$USERS"

# Determine final result
if [ $VULN_COUNT -gt 0 ]; then
    RESULT="FAIL"
    DETAILS="Found $VULN_COUNT vulnerable items out of $CHECK_COUNT checked items:\n\nChecked Items:"
    for item in "${CHECKED_ITEMS[@]}"; do
        DETAILS="$DETAILS\n- $item"
    done
    DETAILS="$DETAILS\n\nVulnerable Items:"
    for item in "${VULN_ITEMS[@]}"; do
        DETAILS="$DETAILS\n- $item"
    done
else
    RESULT="PASS"
    DETAILS="All $CHECK_COUNT checked items have proper permissions:\n"
    for item in "${CHECKED_ITEMS[@]}"; do
        DETAILS="$DETAILS\n- $item"
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
