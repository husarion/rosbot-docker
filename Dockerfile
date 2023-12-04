ARG ROS_DISTRO=humble
ARG PREFIX=
ARG ROSBOT_FW_RELEASE=0.8.0
## ============================ STM32FLASH =================================
# stm32flash needs an older version of glibc (2.28), which is why ubuntu 18.04 was used
FROM ubuntu:18.04 AS stm32flash_builder

ARG ROS_DISTRO
ARG ROSBOT_FW_RELEASE

SHELL ["/bin/bash", "-c"]

# official releases are only for intel archs, so we need to build stm32flash from sources
RUN apt-get update && apt-get install -y \
		curl \
		git \
		build-essential \
		cmake && \
	git clone https://github.com/stm32duino/stm32flash.git && \
	cd stm32flash/ && \
	make all

RUN echo ros_distro=$ROS_DISTRO firmware_release=$ROSBOT_FW_RELEASE

# Copy firmware binaries
RUN curl -L https://github.com/husarion/rosbot_ros2_firmware/releases/download/$ROSBOT_FW_RELEASE/firmware.bin -o /firmware.bin && \
    curl -L https://github.com/husarion/rosbot_ros2_firmware/releases/download/$ROSBOT_FW_RELEASE/firmware.hex -o /firmware.hex

## =========================== Firmware CPU ID ================================

FROM ubuntu:20.04 AS cpu_id_builder

ARG ROSBOT_FW_RELEASE

SHELL ["/bin/bash", "-c"]

# official releases are only for intel archs, so we need to build stm32flash from sources
RUN apt-get update && apt-get install -y \
        curl \
        python3 \
        python3-pip

# build a binary for reading the CPU ID
COPY read_cpu_id/ /read_cpu_id

RUN pip3 install -U platformio && \
    cd /read_cpu_id && \
    pio run && \
    chmod -x .pio/build/olimex_e407/firmware.bin


## =========================== ROS builder ===============================
FROM husarnet/ros:${PREFIX}${ROS_DISTRO}-ros-base AS ros_builder

ARG ROS_DISTRO
ARG PREFIX

SHELL ["/bin/bash", "-c"]

WORKDIR /ros2_ws
RUN mkdir src

COPY ./healthcheck.cpp /

RUN apt-get update && apt-get install -y \
		git \
		python3-pip \
		python3-sh \
		python3-periphery && \
	pip3 install pyserial && \
	MYDISTRO=${PREFIX:-ros}; MYDISTRO=${MYDISTRO//-/} && \
    git clone https://github.com/husarion/rosbot_ros.git src -b ros2-combined-microros && \
	vcs import src < src/rosbot/rosbot_hardware.repos && \
	# it is necessary to remove simulation - otherwise rosdep tries to install dependencies
    rm -r src/rosbot_gazebo && \
    # without this line (using vulcanexus base image) rosdep init throws error: "ERROR: default sources list file already exists:"
    rm -rf /etc/ros/rosdep/sources.list.d/20-default.list && \
	rosdep init && \
    rosdep update --rosdistro $ROS_DISTRO && \
    rosdep install -i --from-path src --rosdistro $ROS_DISTRO -y

	# Create health check package and build
RUN cd src/ && \
	source /opt/$MYDISTRO/$ROS_DISTRO/setup.bash && \
    ros2 pkg create healthcheck_pkg --build-type ament_cmake --dependencies rclcpp nav_msgs && \
    sed -i '/find_package(nav_msgs REQUIRED)/a \
            add_executable(healthcheck_node src/healthcheck.cpp)\n \
            ament_target_dependencies(healthcheck_node rclcpp nav_msgs)\n \
            install(TARGETS healthcheck_node DESTINATION lib/${PROJECT_NAME})' \
            /ros2_ws/src/healthcheck_pkg/CMakeLists.txt && \
    mv /healthcheck.cpp /ros2_ws/src/healthcheck_pkg/src/ && \
    cd .. && \
    # Build
	colcon build --packages-skip \
        ackermann_steering_controller \
        bicycle_steering_controller \
        tricycle_steering_controller \
        ros2_controllers \
        effort_controllers \
        admittance_controller \
        force_torque_sensor_broadcaster \
        forward_command_controller \
        gripper_controllers \
        joint_trajectory_controller \
        position_controllers \
        rqt_joint_trajectory_controller \
        tricycle_controller \
        velocity_controllers  \
        ros2_controllers_test_nodes

## =========================== Final Stage ===============================
FROM husarnet/ros:${PREFIX}${ROS_DISTRO}-ros-core 

ARG ROS_DISTRO
ARG PREFIX

SHELL ["/bin/bash", "-c"]

WORKDIR /ros2_ws

COPY --from=ros_builder /ros2_ws /ros2_ws

RUN apt-get update && apt-get install -y \
        python3-rosdep \
        ros-$ROS_DISTRO-teleop-twist-keyboard && \
    rm -rf /etc/ros/rosdep/sources.list.d/20-default.list && \
	rosdep init && \
    rosdep update --rosdistro $ROS_DISTRO && \
    rosdep install -i --from-path src --rosdistro $ROS_DISTRO -y && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

# copy firmware built in previous stage and downloaded repository
COPY --from=stm32flash_builder /firmware.bin /root/firmware.bin
COPY --from=stm32flash_builder /firmware.hex /root/firmware.hex
COPY --from=stm32flash_builder /stm32flash/stm32flash /usr/bin/stm32flash

COPY --from=cpu_id_builder /read_cpu_id/.pio/build/olimex_e407/firmware.bin /firmware_read_cpu_id.bin

RUN echo $(cat /ros2_ws/src/rosbot/package.xml | grep '<version>' | sed -r 's/.*<version>([0-9]+.[0-9]+.[0-9]+)<\/version>/\1/g') >> /version.txt

COPY ros_entrypoint.sh /
COPY vulcanexus_entrypoint.sh /
COPY healthcheck.sh /

HEALTHCHECK --interval=7s --timeout=2s  --start-period=5s --retries=5 \
    CMD ["/healthcheck.sh"]

# COPY --from=microros_agent_getter /ros2_ws /ros2_ws_microros_agent
COPY microros_localhost_only.xml /

# copy scripts
COPY flash-firmware.py /
COPY flash-firmware.py /usr/bin/
COPY print-serial-number.py /usr/bin/
