#!/bin/bash
set -e

if [[ -v FASTRTPS_DEFAULT_PROFILES_FILE ]]; then
    auxfile=$(mktemp)
    cp --attributes-only --preserve $FASTRTPS_DEFAULT_PROFILES_FILE $auxfile
    cat $FASTRTPS_DEFAULT_PROFILES_FILE | envsubst > $auxfile && mv $auxfile $FASTRTPS_DEFAULT_PROFILES_FILE
fi

# setup ros environment
source "/opt/ros/$ROS_DISTRO/setup.bash"
source "/ros2_ws/install/setup.bash"

exec "$@"
