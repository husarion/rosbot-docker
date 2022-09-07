#!/bin/bash
set -e

# setup ros environment
source "/opt/ros/$ROS_DISTRO/setup.bash"
source "/rosbot_ros/install/setup.bash"

exec "$@"
