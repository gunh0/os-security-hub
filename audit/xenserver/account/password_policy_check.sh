#!/bin/bash

TITLE="Password Policy Configuration Check"
RESULT="PASS"
DETAILS=""

echo $(printf '%.0s-' {1..100})
echo "[*] Starting password policy check..." >&2
echo $(printf '%.0s-' {1..100})

# Get current password policy settings
echo "[*] Reading password settings from /etc/login.defs..." >&2
max_days=$(grep -i "^PASS_MAX_DAYS" /etc/login.defs | awk '{print $2}')
min_days=$(grep -i "^PASS_MIN_DAYS" /etc/login.defs | awk '{print $2}')
min_len=$(grep -i "^PASS_MIN_LEN" /etc/login.defs | awk '{print $2}')

echo "[*] Current settings found:" >&2
echo "[*] PASS_MAX_DAYS = $max_days" >&2
echo "[*] PASS_MIN_DAYS = $min_days" >&2
echo "[*] PASS_MIN_LEN = $min_len" >&2

# Check if values are default
echo "[*] Checking if values match default settings..." >&2
if [ "$max_days" = "99999" ] && [ "$min_days" = "0" ] && [ "$min_len" = "5" ]; then
   RESULT="FAIL"
   echo "[*] Default values detected - marking as FAIL" >&2
   DETAILS="Password policy is using default values (PASS_MAX_DAYS=99999, PASS_MIN_DAYS=0, PASS_MIN_LEN=5). Security policy has not been applied."
else
   echo "[*] Non-default values detected - marking as PASS" >&2
   DETAILS="Password policy has been modified from default values. Current settings: PASS_MAX_DAYS=$max_days, PASS_MIN_DAYS=$min_days, PASS_MIN_LEN=$min_len"
fi

echo "[*] Generating final report..." >&2
cat <<EOF
{
   "title": "$TITLE",
   "result": "$RESULT",
   "details": "$DETAILS",
   "timestamp": "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
}
EOF
