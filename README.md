# rosbot-docker

Docker Image for ROS Humble Node providing interface for STM32 firmware over [Micro-Ros](https://micro.ros.org/).

`rosbot-docker` contain following ROS packages:
- [rosbot_ros](https://github.com/husarion/rosbot_ros/tree/humble)

With *docker-compose* configuration shown in [demo](./demo) it can communicate with hardware of both Rosbot 2.0 and Rosbot 2.0 Pro.

## Flashing the firmware

Firmware if flashed from inside of the container.

``` bash
docker run --rm -it --privileged \
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


### Subscribes

- `/cmd_vel` (*geometry_msgs/Twist*, **/rosbot_base_controller**)
- `/_motors_response` (*sensor_msgs/msg/JointState*, **/rosbot_stm32_firmware**)
- `/_imu/data_raw` (*sensor_msgs/msg/Imu*, **/imu_sensor_node**)

### Publishes
- `/battery` (*sensor_msgs/BatteryState*, **/rosbot_stm32_firmware**)
- `/imu_broadcaster/imu` (*sensor_msgs/Imu*, **/imu_broadcaster**)
- `/rosbot_base_controller/odom` (*nav_msgs/Odometry*, **/rosbot_base_controller**)
- `/odometry/filtered` (*nav_msgs/Odometry*, **/ekf_node**)
- `/_motors_cmd` (*std_msgs/msg/Float32MultiArray*, **/rosbot_stm32_firmware**)
- `/range/right_front` (*sensor_msgs/msg/Range*, **/rosbot_stm32_firmware**)
- `/range/left_front` (*sensor_msgs/msg/Range*, **/rosbot_stm32_firmware**)
- `/range/right_rear` (*sensor_msgs/msg/Range*, **/rosbot_stm32_firmware**)
- `/range/left_rear` (*sensor_msgs/msg/Range*, **/rosbot_stm32_firmware**)

For more details on what is being published and subscribed by nodes running in this container please refer to launch file and packages:
- [rosbot_ros](https://github.com/husarion/rosbot_ros/tree/humble)
- [rosbot-stm32-firmware](https://github.com/husarion/rosbot-stm32-firmware/tree/ros2)

## Autonomous Navigation Demo

in a [/demo](/demo) folder your will find an example of how to use ROSbot docker image in a real autonomous navigation use case.

![](demo/.docs/rviz_mapping.png)