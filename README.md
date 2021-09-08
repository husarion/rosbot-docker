# rosbot-docker
Docker Image for ROS Melodic Node providing interface for STM32 firmware over ROS-serial.

`rosbot-docker` contain following ROS packages:
- [rosbot_description](https://github.com/husarion/rosbot_description)
- [rosbot_ekf](https://github.com/husarion/rosbot_ekf)

With *docker-compose* configuration shown in [examples](./examples) it can communicate with hardware of both Rosbot 2.0 and Rosbot 2.0 Pro.

## Flashing firmware | switch kinematics

Firmware if flashed from inside of container. In order to use specific kinematics flash matching firmware.

For differential drive flash firmware with:
``` bash
cd examples/rosbot_flash_firmware_diff
docker-compose up
 ```

 For mecanum kinematics flash firmware with:

``` bash
cd examples/rosbot_flash_firmware_mecanum
docker-compose up
 ```

## Running examples

Running examples is similar as it is shown in flashing firmware step.
 ``` bash
cd examples/<rosbot example>
docker-compose up
 ```

## Configuring Orbbec Astra

In *docker-compose.yaml* you have to change `device` passed to docker. For more information refer to `astra-docker` [README.md](https://github.com/husarion/astra-docker)


## ROS node

Most important nodes published by this docker after launching [rosbot_docker.launch](https://github.com/husarion/rosbot_description/blob/master/src/rosbot_description/launch/rosbot_docker.launch) are shown below.

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
- [rosbot_description](https://github.com/husarion/rosbot_description)
- [rosbot_ekf](https://github.com/husarion/rosbot_ekf)
- [rosbot-stm32-firmware](https://github.com/husarion/rosbot-stm32-firmware)