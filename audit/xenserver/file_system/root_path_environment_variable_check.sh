#!/bin/bash
TITLE="Root PATH Environment Variable Check"
RESULT="PASS"
DETAILS=""

echo $(printf '%.0s-' {1..100}) >&2
echo "[*] Starting root PATH environment variable check..." >&2
echo $(printf '%.0s-' {1..100}) >&2

# Get root's PATH from environment or profile files
echo "[*] Checking root's PATH environment variable..." >&2

# First try to get PATH from root's environment
ROOT_PATH=$(sudo -i env | grep '^PATH=' | cut -d= -f2)

echo "[*] Found PATH: $ROOT_PATH" >&2
echo "[*] Analyzing PATH directories..." >&2

# Split PATH into array for analysis
IFS=: read -ra PATHS <<<"$ROOT_PATH"

echo "[*] Found ${#PATHS[@]} directories in PATH:" >&2
for i in "${!PATHS[@]}"; do
    echo "   - Directory $((i + 1)): ${PATHS[$i]}" >&2
done

echo "[*] Checking for current directory (.) in PATH..." >&2
# Check if PATH contains "."
if [[ "$ROOT_PATH" == *"."* ]]; then
    echo "[*] Current directory (.) found in PATH" >&2

    # Find position of "."
    DOT_POS=0
    TOTAL_PATHS=${#PATHS[@]}

    for i in "${!PATHS[@]}"; do
        if [ "${PATHS[$i]}" = "." ]; then
            DOT_POS=$((i + 1))
            break
        fi
    done

    echo "[*] Position of '.' in PATH: $DOT_POS of $TOTAL_PATHS" >&2

    if [ $DOT_POS -eq $TOTAL_PATHS ]; then
        RESULT="PASS"
        DETAILS="Current directory (.) is present in PATH but located at the end"
        echo "[*] Current directory is at the end of PATH - acceptable" >&2
    else
        RESULT="FAIL"
        DETAILS="Current directory (.) is present in PATH at position $DOT_POS of $TOTAL_PATHS (should be at end or not present)"
        echo "[!] WARNING: Current directory is not at the end of PATH" >&2
    fi
else
    RESULT="PASS"
    DETAILS="Current directory (.) is not present in PATH"
    echo "[*] Current directory (.) is not found in any position - secure configuration" >&2
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
