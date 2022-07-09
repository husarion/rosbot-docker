# rosbot-docker

Docker Image for ROS Melodic Node providing interface for STM32 firmware over ROS-serial.

`rosbot-docker` contain following ROS packages:
- [rosbot_ros](https://github.com/husarion/rosbot_ros)
- [rosbot_ekf](https://github.com/husarion/rosbot_ekf)

With *docker-compose* configuration shown in [demo](./demo) it can communicate with hardware of both Rosbot 2.0 and Rosbot 2.0 Pro.

## Flashing the firmware | switch kinematics

Firmware if flashed from inside of the container. In order to use specific kinematics flash matching firmware.

### Differential kinematics (normal wheels)

``` bash
docker run --rm -it --privileged \
husarion/rosbot:noetic \
/flash-firmware.py /root/firmware_diff.bin
```

### Mecanum kinematics

```bash
docker run --rm -it --privileged \
husarion/rosbot:noetic \
/flash-firmware.py /root/firmware_mecanum.bin
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

Most important nodes published by this docker after launching [rosbot_docker.launch](https://github.com/husarion/rosbot_ros/blob/melodic/src/rosbot_bringup/launch/rosbot_docker.launch) are shown below.

### Subscribes

- `/cmd_vel` (*geometry_msgs/Twist*, **/serial_bridge**)

### Publishes

- `/tf` (*tf2_msgs/TFMessage*, **/rosbot_ekf**)
- `/tf_static` (*tf2_msgs/TFMessage*, **/imu_publisher**, **/laser_publisher**, **/camera_publisher**)
- `/odom` (*nav_msgs/Odometry*, **/rosbot_ekf**)
- `/imu` (*sensor_msgs/Imu*, **/serial_bridge**)
- `/battery` (*sensor_msgs/BatteryState*, **/serial_bridge**)
- `/range/fl` (*sensor_msgs/Range*, **/serial_bridge**)
- `/range/fr` (*sensor_msgs/Range*, **/serial_bridge**)
- `/range/rl` (*sensor_msgs/Range*, **/serial_bridge**)
- `/range/rr` (*sensor_msgs/Range*, **/serial_bridge**)

For more details on what is being published and subscribed by nodes running in this container please refer to launch file and packages:
- [rosbot_ros](https://github.com/husarion/rosbot_ros)
- [rosbot_ekf](https://github.com/husarion/rosbot_ekf)
- [rosbot-stm32-firmware](https://github.com/husarion/rosbot-stm32-firmware)