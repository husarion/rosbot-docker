#!/bin/bash

# HEALTHCHECK_FILE="/var/tmp/health_status.txt"

# # Now check the health status
# if [ -f "$HEALTHCHECK_FILE" ]; then
#     status=$(cat "$HEALTHCHECK_FILE")
#     if [ "$status" == "healthy" ]; then
#         exit 0
#     else
#         exit 1
#     fi
# else
#     echo "Healthcheck file still not found. There may be an issue with the node."
#     exit 1
# fi

# FIXME: # <additional-user-commands> gosu commands are used before creation the user
LOCKFILE="/tmp/script_lockfile"

if [[ -f "$LOCKFILE" ]]; then
    START_TIME=$(cat "$LOCKFILE")
    CURRENT_TIME=$(date +%s)

    if (( CURRENT_TIME - START_TIME >= 20 )); then
        rm -f "$LOCKFILE"
        exit 0
    else
        exit 1
    fi
else
    date +%s > "$LOCKFILE"
    exit 1
fi
