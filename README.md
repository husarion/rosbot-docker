# rosbot-docker
Docker Image for ROS Melodic Node providing interface for STM32 firmware over ROS-serial.

## Building a Docker image

```bash
sudo docker build -t rosbot .
```

## Running a Docker container

```bash
sudo docker run --rm -it \
rosbot 
```

## Examples (using Docker Compose)

### RPLIDAR + Astra + ROSbot containers and Rviz container

Login to ROSbot's desktop (remote desktop/VNC or just HDMI screen + mouse + keyboard). Clone this repository and:

```bash
cd rosbot-docker/examples/rosbot_rplidar_astra_rviz

xhost local:root
docker-compose up --build
```

> **Note 1:** that in the above `docker-compose.yml` every `up` command we reflash the image for STM32:
> 
> ```yml
>   rosbot:
>     build:
>       context: ../../ 
>       dockerfile: ./Dockerfile
>     tty: true        # docker run -t
>     privileged: true
>     command: 
>       - bash
>       - -c
>       - |
>         ./flash_firmware.sh
>         roslaunch rosbot_description serialbridge_only.launch
> ```
>
> To do not reflash it every re-run, just remove the line `./flash_firmware.sh`

## Running examples

To run any of examples please go to `/examples` + one of subfolder, then type `docker-compose up` to start container. 

When running without screen you can comment (using "`#`") rviz2 service from `docker-compose.yml`

Short description:

1. `rosbot_base` --> launches rosbot, rviz2, core2 communication - you can drive with teleop-keyboard and other basic functionalities. 
2. `rosbot_rplidar` --> it's rosbot_base + rplidar node
3. `rosbot_rplidar_astra_rviz` --> it's rosbot_rplidar + astra camera node
4. `rosbot_rplidar_astra_rviz_host_network` --> it's rosbot_rplidar_astra_rviz but in different network configuration to use correctly change HOST_IP to your device IP address. Apply this change in .env file located inside `examples/rosbot_rplidar_astra_rviz_host_network/.env`
5. `rosbot_flash_firmware` --> image for flashing the newest firmware (advise - run it from time to time to get fresh firmware) (unchangable works for Rosbot 2.0 and Rosbot 2.0 PRO)

### ROSBOT_PRO

To run this on Rosbot2.0 PRO you have to change `SERIAL_PORT` value and `devices` in desired `docker-compose.yml`

```bash
environment:
- "ROS_MASTER_URI=http://my-ros-master:11311"
- "SERIAL_PORT=/dev/ttyS4" # (change for Rosbot 2.0 PRO) default: ttyS1 - rosbot2.0; ttyS4 - rosbot2.0 pro
devices:
- "/dev/ttyS4"   # (change for Rosbot 2.0 PRO) must match environment SERIAL_PORT default: ttyS1 - rosbot2.0; ttyS4 - rosbot2.0 pro
```

Also remember to change to appropiriate rplidar model matching your rosbot [list-of-launches](https://github.com/Slamtec/rplidar_ros/tree/master/launch) in rplidar service

```bash
rplidar:
    image: husarion/rplidar:latest
    restart: unless-stopped
    environment:

        - "ROS_MASTER_URI=http://my-ros-master:11311"
    devices:
      - /dev/ttyUSB0
    tty: true 
    network_mode: host       
    command: roslaunch rplidar_ros rplidar_a3.launch # For Rosbot 2.0 PRO use roslaunch rplidar_ros rplidar_a3.launch
```

To see example go to `examples/rosbot_pro_base/docker-compose.yml` .
### Known errors

In case of errors while flashing or reading data from CORE2 check following

1. `docker container ls` - list all running containers look for running containers
2. when names of containers are linked to `rosbotflashfirmware` or `rosbotserial` kill them before flashing/reading
3. to kill all containers use `docker kill $(docker ps -q)`