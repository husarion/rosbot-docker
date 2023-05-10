# rosbot-docker

Docker Image for ROS Humble Node providing interface for STM32 firmware over [Micro-ROS](https://micro.ros.org/).

`rosbot-docker` contain following ROS packages:
- [rosbot_ros](https://github.com/husarion/rosbot_ros/tree/humble)

With *docker-compose* configuration shown in [demo](./demo) it can communicate with hardware of both Rosbot 2.0 and Rosbot 2.0 Pro.

## Flashing the firmware

Firmware if flashed from inside of the container running on the ROSbot:

``` bash
docker run \
--rm -it --privileged \
husarion/rosbot:humble \
/flash-firmware.py /root/firmware.bin
```

## Building locally

``` bash
docker buildx build \
--platform linux/amd64 \
-t rosbot-docker-test \
.
```

<!-- ## Configuring Orbbec Astra

In *docker-compose.yaml* you have to change `device` passed to docker. For more information refer to `astra-docker` [README.md](https://github.com/husarion/astra-docker) -->


## ROS node

Most important nodes published by this docker after launching [rosbot_bringup.launch.py](https://github.com/husarion/rosbot_ros/blob/humble/src/rosbot_bringup/launch/rosbot_bringup.launch.py) are shown below.

For more details on what is being published and subscribed by nodes running in this container please refer to launch file and packages:
- [rosbot_ros](https://github.com/husarion/rosbot_ros/tree/humble)
- [rosbot_ros2_firmware](https://github.com/husarion/rosbot_ros2_firmware/)

## How to use `rosbot` Docker image?

Find available projects below:

| link | description |
| - | - |
| [rosbot-sensors](./demo/) | Visualize all ROSbot sensors |
| [rosbot-gamepad](https://github.com/husarion/rosbot-gamepad) | Control the robot manually using a Logitech F710 gamepad |
| [rosbot-mapping](https://github.com/husarion/rosbot-mapping) | Create a map (using [slam_toolbox](https://github.com/SteveMacenski/slam_toolbox)) of the unknow environment with ROSbot controlled in LAN or over the Internet |
| [rosbot-navigation](https://github.com/husarion/rosbot-navigation) | Autonomous navigation (using [navigation2](https://github.com/ros-planning/navigation2)) on a given map.  |
