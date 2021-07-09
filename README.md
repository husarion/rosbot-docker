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
