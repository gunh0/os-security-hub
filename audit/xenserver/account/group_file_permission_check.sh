#!/bin/bash

TITLE="Group File Permission Check"
RESULT="PASS"
DETAILS=""

# Check /etc/group file ownership and permissions
GROUP_FILE="/etc/group"
OWNER=$(stat -c %U $GROUP_FILE)
PERMISSION=$(stat -c %a $GROUP_FILE)

# Check if owner is root or bin and permissions are 644
if [[ "$OWNER" =~ ^(root|bin)$ ]] && [ "$PERMISSION" -eq 644 ]; then
    RESULT="PASS"
    DETAILS="$GROUP_FILE file has correct ownership ($OWNER) and permissions ($PERMISSION)"
else
    RESULT="FAIL"
    if [[ ! "$OWNER" =~ ^(root|bin)$ ]]; then
        DETAILS="$GROUP_FILE file ownership is incorrect (current: $OWNER, required: root or bin). "
    fi
    if [ "$PERMISSION" -ne 644 ]; then
        DETAILS+="$GROUP_FILE file permissions are incorrect (current: $PERMISSION, required: 644)"
    fi
fi

cat <<EOF
{
    "title": "$TITLE",
    "result": "$RESULT",
    "details": "$DETAILS",
    "timestamp": "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
}
EOF
