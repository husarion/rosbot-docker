# Demo

These docker-compose .yaml configurations present how to run autonomous mapping and navigation demo with ROSbot and [Navigation2](https://navigation.ros.org/) stack. 

There are two phases:

1. **Creating a map** - navigation and creating a map by using [slam-toolbox](https://github.com/SteveMacenski/slam_toolbox)
2. **Localization on an already created map** - Navigation based on created map - with [AMCL](https://navigation.ros.org/configuration/packages/configuring-amcl.html)

Both cases are presented below in three setups: 

1. In a Local Area Network (LAN) - the robot running navigation stack and PC / laptop running RViz are in the same Wi-Fi network.
2. Over the Internet (VPN) - the robot and the laptop can be in separate networks.
3. Gazebo simulation.

> **Prerequisites**
>
> Make sure you have [Docker and Docker-Compose](https://docs.docker.com/desktop/install/linux-install/) installed on your laptop. 
> 
> If you don't have, here's a quick summary for Ubuntu 20.04 (just click the `copy` button, and paste it to the Linux terminal):
> ```bash
> sudo apt-get update && sudo apt-get install -y ca-certificates curl gnupg lsb-release
> ```
> ```bash
> sudo mkdir -p /etc/apt/keyrings
> ```
> ```bash
> curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
> ```
> ```bash
> echo \
>  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
>  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
> ```
> ```bash
> sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
> ```


## Quick start (Physical ROSbot)

### 1. Clone this repo **on your laptop**

```bash
git clone https://github.com/husarion/rosbot-docker/
```

### 2. Prepare `demo/.env` file

```bash
cd rosbot-docker/demo
cp .env.template .env
```

modify it if needed (see comments)

> **Warning**
>
> Make sure you have Docker Compose with at least `v2.3.0` version installed on your PC/laptop
>
> ```bash
> $ docker compose version
> Docker Compose version v2.3.3
> ```
>
> Inline comments in `.env` files are supported from this version

```bash
# ======================================================
# For LAN examples you need to have unique ROS_DOMAIN_ID to 
# avoid reading messages from other robots in the network
#
# ROS_DOMAIN_ID has to be in range 0-232
======================================================

ROS_DOMAIN_ID=79

# ======================================================
# SBC <> STM32 serial connection.
# ======================================================

# SERIAL_PORT=/dev/ttyS1     # ROSbot 2
# SERIAL_PORT=/dev/ttyS4     # ROSbot 2 PRO
SERIAL_PORT=/dev/ttyAMA0   # ROSbbot 2R

# ======================================================
# Serial baudrate for rplidar driver
# ======================================================

RPLIDAR_BAUDRATE=115200     # RPLIDAR A2
# RPLIDAR_BAUDRATE=256000     # RPLIDAR A3

# ======================================================
# For simulation example you need to use simulation time
# ======================================================

USE_SIM_TIME=False      # for a physical ROSbot
# USE_SIM_TIME=True       # for a Gazebo simulation

# ======================================================
# DDS implementation
# ======================================================

RMW_IMPLEMENTATION=rmw_fastrtps_cpp         # for eProsima’s Fast DDS
# RMW_IMPLEMENTATION=rmw_cyclonedds_cpp       # or Eclipse’s Cyclone DDS

# ======================================================
# Uncomment for compose.*.vpn.yaml files and paste 
# your own Husarnet Join Code from app.husarnet.com here:
# ======================================================

# JOINCODE=fc94:b01d:1803:8dd8:b293:5c7d:7639:932a/xxxxxxxxxxxxxxxxxxxxxx
```

If you have other ROS 2 devices running in your LAN network make sure to provide a unique `ROS_DOMAIN_ID` (the default value is `ROS_DOMAIN_ID=0`) and select the right `SERIAL_PORT` depending on your ROSbot version (ROSbot 2 / ROSbot 2 PRO / ROSbot 2R). Note that if you run the demo example in a **simulation** then `SERIAL_PORT` is ignored, but it is necessary to define the `USE_SIM_TIME` variable to `True`.

### 3. Sync your workspace with the ROSbot

> **Prerequisites**
>
> Install [unison](https://en.wikipedia.org/wiki/Unison_(software)) and [inotify-tools](https://github.com/inotify-tools/inotify-tools/wiki) and [rsync](https://en.wikipedia.org/wiki/Rsync):
>
> ```bash
> sudo sudo apt-get update && sudo apt-get install -y unison inotify-tools rsync
> ```

In the `demo/` folder, there is a script for auto-syncing this repo with ROSbot (you do not need to manually change the same repo on ROSbot and on the laptop).

If IP address of your robot is `10.5.10.64`, run:

```bash
./sync_with_rosbot.sh 10.5.10.64
```
In order to allow changes on ROSbot to affect demo directory on your PC (for example for viewing saved map) use `--bidirectional` flag:

```bash
./sync_with_rosbot.sh 10.5.10.64 --bidirectional
```


### 4. Flash the microcontroller 

To flash the right firmware, open ROSbot's terminal or connect via `ssh` and execute this command:
   
- for differential drive (regular wheels):
   
```bash
docker run --rm -it --privileged \
husarion/rosbot:noetic \
/flash-firmware.py /root/firmware_diff.bin
```
- for omnidirectional wheeled ROSbot (mecanum wheels):

```bash
docker run --rm -it --privileged \
husarion/rosbot:noetic \
/flash-firmware.py /root/firmware_mecanum.bin
```

### 5. [Optional] VPN config

If in the next steps you want to run VPN configuration get your Husarnet Join Code and paste it as a value for `JOINCODE` environment variable in the `.env` file.

You will find your **Husarnet Join Code** on your account at Husarnet Dashboard:

1. Log in to https://app.husarnet.com/
2. Select or create a network
3. Click **[Add element]** button and select a **Join Code** tab:

In this example, [Husarnet P2P VPN](https://husarnet.com/) is used for providing over the Internet connectivity. Default DDS discovery using multicasting doesn't work therefore IPv6 addresses provided by Husarnet VPN need to be applied to a peer list in a `dds-config.xml` file. To do not copy those IPv6 addresses there is a simple utility script that does it for you. Everything you need to do is to launch it **ONLY ONCE** and make sure to have **THE SAME** `secret/` on both devices:

Execute these commands in the Linux terminal

```bash
./generate-vpn-config.sh
```

### 6. Create a map
> **Enabling display**
> 
> In order to use GUI of applications running in containers (like rviz) run:
> ``` bash
> xhost local:root
> ```
> on your PC, before starting those containers
>


Depending on the network configuration (LAN/VPN) execute the chosen pair of commands in the PC or ROSbot's terminal:

<table>

<!-- ------------------------------------------------- -->

<tr>

<th> </th> 
<th> LAN </th> 
<th> VPN </th>

</tr>

<!-- ------------------------------------------------- -->

<tr>

<td>
<b>PC / laptop</b>
</td> 

<td>  


```
docker compose \
-f compose.rviz.yaml \
-f compose.rviz.lan.yaml \
up
```

</td>

<td>  



```
docker compose \
-f compose.rviz.yaml \
-f compose.rviz.vpn.yaml \
up
```

</td>

</tr>

<!-- ------------------------------------------------- -->

<tr>

<td> 
<b>ROSbot</b>
</td> 

<td>  

```bash
docker compose \
-f compose.rosbot.hardware.yaml \
-f compose.rosbot.mapping.yaml \
-f compose.rosbot.lan.yaml \
up
```

</td>

<td>  


```bash
docker compose \
-f compose.rosbot.hardware.yaml \
-f compose.rosbot.mapping.yaml \
-f compose.rosbot.vpn.yaml \
up
```

</td>

</tr>

<!-- ------------------------------------------------- -->

</table>

Prepare map with Rviz2 using **2D Goal Pose**.

![](./docs/nav2_goal.png)

After you create the map, open a new terminal on ROSbot, navigate to `demo/` folder and execute:

```bash
./map-save.sh
```

Your map has been saved in docker volume and is now in the `maps/` folder.

### 7. Localization on an already created map
Depending on the network configuration (LAN/VPN) execute the chosen pair of commands in the PC or ROSbot's terminal:

<table>

<!-- ------------------------------------------------- -->

<tr>

<th> </th> 
<th> LAN </th> 
<th> VPN </th>

</tr>

<!-- ------------------------------------------------- -->

<tr>

<td> 
<b>PC / laptop</b>
</td> 

<td>  


```
docker compose \
-f compose.rviz.yaml \
-f compose.rviz.lan.yaml \
up
```

</td>

<td>  

```
docker compose \
-f compose.rviz.yaml \
-f compose.rviz.vpn.yaml \
up
```

</td>

</tr>

<!-- ------------------------------------------------- -->

<tr>

<td> 
<b>ROSbot</b>
</td> 

<td>  

```bash
docker compose \
-f compose.rosbot.hardware.yaml \
-f compose.rosbot.localization.yaml \
-f compose.rosbot.lan.yaml \
up
```

</td>

<td>  


```bash
docker compose \
-f compose.rosbot.hardware.yaml \
-f compose.rosbot.localization.yaml \
-f compose.rosbot.vpn.yaml \
up
```

</td>

</tr>

<!-- ------------------------------------------------- -->

</table>

Set initial pose of ROSbot using `2D Pose Estimate` and navigate with `Nav2 Goal`.

![](./docs/2d_pose_estimate.png)

## Quick start (simulation model of ROSbot in Gazebo)


### 1. Clone this repo **on your laptop**

```bash
git clone https://github.com/husarion/rosbot-docker/
```

### 2. Prepare `demo/.env` file

```bash
cd rosbot-docker/demo
cp .env.template .env
```

modify it if needed (see comments)

```bash
# ======================================================
# For LAN examples you need to have unique ROS_DOMAIN_ID to 
# avoid reading messages from other robots in the network
# 
# ROS_DOMAIN_ID has to be in range 0-232
======================================================

ROS_DOMAIN_ID=79

# ======================================================
# SBC <> STM32 serial connection.
# ======================================================

# SERIAL_PORT=/dev/ttyS1     # ROSbot 2
# SERIAL_PORT=/dev/ttyS4     # ROSbot 2 PRO
SERIAL_PORT=/dev/ttyAMA0   # ROSbbot 2R

# ======================================================
# Serial baudrate for rplidar driver
# ======================================================

RPLIDAR_BAUDRATE=115200     # RPLIDAR A2
# RPLIDAR_BAUDRATE=256000     # RPLIDAR A3

# ======================================================
# For simulation example you need to use simulation time
# ======================================================

# USE_SIM_TIME=False      # for a physical ROSbot
USE_SIM_TIME=True       # for a Gazebo simulation

# ======================================================
# DDS implementation
# ======================================================

RMW_IMPLEMENTATION=rmw_fastrtps_cpp         # for eProsima’s Fast DDS
# RMW_IMPLEMENTATION=rmw_cyclonedds_cpp       # or Eclipse’s Cyclone DDS

# ======================================================
# Uncomment for compose.*.vpn.yaml files and paste 
# your own Husarnet Join Code from app.husarnet.com here:
# ======================================================

# JOINCODE=fc94:b01d:1803:8dd8:b293:5c7d:7639:932a/xxxxxxxxxxxxxxxxxxxxxx
```

### 3. Create a map

On your PC with launch:

```bash
xhost local:root
```

```bash
docker compose \
-f compose.rosbot.simulation.yaml \
-f compose.rosbot.mapping.yaml \
-f compose.rviz.yaml \
up
```

In Rviz2 window, click the **[Startup]** button in the "**Navigation 2**" field.

Prepare a map with Rviz2 using 2D Goal Pose and [save the map](https://github.com/husarion/rosbot-docker/tree/ros1/demo#saving-the-map).


[![Watch the video](https://img.youtube.com/vi/OiZTFYMlgis/default.jpg)](https://youtu.be/OiZTFYMlgis)

### 4. Localization on an already created map

Next launch `Navigation2` stack with `AMLC`:

```bash
xhost local:root
```

```bash
docker compose \
-f compose.rosbot.simulation.yaml \
-f compose.rosbot.localization.yaml \
-f compose.rviz.yaml \
up 
```

### Results:

[![Watch the video](https://img.youtube.com/vi/j_tRVuZiR18/default.jpg)](https://youtu.be/j_tRVuZiR18)

