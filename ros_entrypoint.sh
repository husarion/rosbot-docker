#!/bin/bash
set -e

# Run husarnet-dds singleshot and capture the output
output=$(husarnet-dds singleshot || true)
[[ "$HUSARNET_DDS_DEBUG" == "TRUE" ]] && echo "$output"

# Setup ROS environment
source "/opt/ros/$ROS_DISTRO/setup.bash"
test -f "/ros2_ws/install/setup.bash" && source "/ros2_ws/install/setup.bash"

# Run healthcheck in the background
ros2 run healthcheck_pkg healthcheck_node &

# Execute additional commands
exec "$@"
