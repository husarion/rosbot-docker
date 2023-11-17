#!/bin/bash

HEALTHCHECK_FILE="/health_status.txt"

# Function to start the ROS 2 healthcheck node
start_healthcheck_node() {
    /ros_entrypoint.sh ros2 run healthcheck_pkg healthcheck_node &
}

if [ ! -f "$HEALTHCHECK_FILE" ]; then
    echo "Healthcheck file not found. Starting ROS 2 healthcheck node..."
    start_healthcheck_node
    # Wait a bit to allow the node to start and write its initial status
    sleep 5
fi

# Now check the health status
if [ -f "$HEALTHCHECK_FILE" ]; then
    status=$(cat "$HEALTHCHECK_FILE")
    if [ "$status" == "healthy" ]; then
        exit 0
    else
        exit 1
    fi
else
    echo "Healthcheck file still not found. There may be an issue with the node."
    exit 1
fi
