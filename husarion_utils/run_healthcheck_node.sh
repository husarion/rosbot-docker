source "/healthcheck_ws/install/setup.bash"
if [ -n "$ROBOT_NAMESPACE" ]; then
    gosu $USER bash -c "ros2 run healthcheck_pkg healthcheck_node --ros-args -r __ns:=/$ROBOT_NAMESPACE &"
else
    gosu $USER bash -c "ros2 run healthcheck_pkg healthcheck_node &"
fi
