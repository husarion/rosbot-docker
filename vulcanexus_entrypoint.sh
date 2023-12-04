#!/bin/bash
set -e

output=$(husarnet-dds singleshot) || true
if [[ "$HUSARNET_DDS_DEBUG" == "TRUE" ]]; then
  echo "$output"
fi

# Check if XRCE_DOMAIN_ID_OVERRIDE is unset or empty
if [ -z "$XRCE_DOMAIN_ID_OVERRIDE" ]; then
    # If ROS_DOMAIN_ID is set and not empty, set XRCE_DOMAIN_ID_OVERRIDE to its value
    if [ -n "$ROS_DOMAIN_ID" ]; then
        export XRCE_DOMAIN_ID_OVERRIDE="$ROS_DOMAIN_ID"
    fi
fi

# setup ros environment
source "/opt/vulcanexus/$ROS_DISTRO/setup.bash"
source  "/ros2_ws/install/setup.bash"

ros2 run healthcheck_pkg healthcheck_node &

exec "$@"
