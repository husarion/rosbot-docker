# rosbot-docker

Docker Image for ROS Humble Node providing interface for STM32 firmware over [Micro-ROS](https://micro.ros.org/).

`rosbot-docker` contain following ROS packages:
- [rosbot_ros](https://github.com/husarion/rosbot_ros/tree/humble)

With *docker-compose* configuration shown in [demo](./demo) it can communicate with hardware of ROSbot 2R, ROSbot 2 PRO and ROSbot 2.0.

## Quick Start

```yaml
services:

  rosbot:
    image: husarion/rosbot:humble
    devices:
      - ${SERIAL_PORT:?err}
      - /dev/bus/usb/ # FTDI (if connecting over USB port with STM32)
    environment:
      - ROS_DOMAIN_ID=30
    command: >
      ros2 launch rosbot_bringup combined.launch.py
        mecanum:=${MECANUM:-False}
        serial_port:=$SERIAL_PORT
        serial_baudrate:=576000
        namespace:=robot1
```

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


## Reading CPU id

```bash
docker run \
--rm -it --privileged \
husarion/rosbot:humble \
print-serial-number.py
```

## ROS node

Most important nodes published by this docker after launching [rosbot_bringup.launch.py](https://github.com/husarion/rosbot_ros/blob/humble/src/rosbot_bringup/launch/rosbot_bringup.launch.py) are shown below.

For more details on what is being published and subscribed by nodes running in this container please refer to launch file and packages:
- [rosbot_ros](https://github.com/husarion/rosbot_ros/tree/humble)
- [rosbot_ros2_firmware](https://github.com/husarion/rosbot_ros2_firmware/)


## Developing
[pre-commit configuration](.pre-commit-config.yaml) prepares plenty of tests helping for developing and contributing. Usage:

```bash
# install pre-commit
pip install pre-commit

# initialize pre-commit workspace
pre-commit install

# manually run tests
pre-commit run -a
```

## How to use `rosbot` Docker image?

Find available projects below:

| link | description |
| - | - |
| [rosbot-sensors](https://github.com/husarion/rosbot-sensors) | Visualize all ROSbot sensors |
| [rosbot-gamepad](https://github.com/husarion/rosbot-gamepad) | Control the robot manually using a Logitech F710 gamepad |
| [rosbot-telepresence](https://github.com/husarion/rosbot-telepresence) | Stream a live video from Orbbec Astra to a window on your PC. Control the robot using `teleop-twist-keyboard` ||
| [rosbot-autonomy](https://github.com/husarion/rosbot-autonomy) | A combination of `mapping` and `navigation` projects allowing simultaneous mapping and navigation in unknown environments.  |
