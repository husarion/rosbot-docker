# rosbot-docker
Docker Image for ROS Melodic Node providing interface for STM32 firmware over ROS-serial.

`rosbot-docker` contain following ROS packages:
- [rosbot_description](https://github.com/husarion/rosbot_description)
- [rosbot_ekf](https://github.com/husarion/rosbot_ekf)

With *docker-compose* configuration shown in [examples](./examples) it can communicate with hardware of both Rosbot 2.0 and Rosbot 2.0 Pro.

## Building a Docker image

```bash
docker build -t rosbot .
```

## Running a Docker container

```bash
docker run --rm -it rosbot 
```

## Flashing firmware

Firmware if flashed from inside of container.
 ``` bash
cd examples/rosbot_flash_firmware
docker-compose up
 ```

## Running examples

Running examples is similar as it is shown in flashing firmware step.
 ``` bash
cd examples/<rosbot example>
docker-compose up
 ```
