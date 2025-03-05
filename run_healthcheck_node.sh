if [ ! -z "$USER" ] && [ "$USER" != "root" ] && [ "$USER" != "$(whoami)" ]; then
    # Check if the user already exists; if not, create the user
    if ! id "$USER" &>/dev/null; then
        useradd -ms /bin/bash "$USER"
        echo "[ \"\$(whoami)\" != \"$USER\" ] && su - \"$USER\"" >> /etc/bash.bashrc
    fi

    source "/ros2_ws_healthcheck/install/setup.bash"

    exec gosu $USER /bin/bash -c "ros2 run healthcheck_pkg healthcheck_node &"

else
    source "/ros2_ws_healthcheck/install/setup.bash"
    ros2 run healthcheck_pkg healthcheck_node &
fi
