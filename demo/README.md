# Demos
Compose configuration that allows you to control ROSbot 2 / ROSbot 2 PRO / ROSbot 2R with [Navigation2](https://navigation.ros.org/) stack and [slam-toolbox](https://github.com/SteveMacenski/slam_toolbox).

# Quick start

## Prerequisites ###

1. Make sure the right version of firmware for STM32F4 MCU is flashed on ROSbot. To flash the right firmware, open ROSbot's terminal or connect via `ssh` and execute this command:
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

2. Clone this repo on your PC:

    ```bash
    git clone https://github.com/husarion/rosbot-docker.git
    cd rosbot-docker/
    ```

3. Create `demo/.env` based on `demo/.env.template` file and modify it if needed (see comments)

    ```bash
    # For LAN examples you need to have unique ROS_DOMAIN_ID to avoid reading messages from other robots in the network
    ROS_DOMAIN_ID=228

    # For simulation example you need to use simulation time
    USE_SIM_TIME=False

    # SBC <> STM32 serial connection. 
    # Set:
    # /dev/ttyS1    for ROSbot 2
    # /dev/ttyS4    for ROSbot 2 PRO
    # /dev/ttyAMA0  for ROSbbot 2R
    SERIAL_PORT=/dev/ttyS4

    # Serial baudrate for rplidar driver
    # Set:
    # 115200        for A2  
    # 256000        for A3 
    RPLIDAR_BAUDRATE=256000

    ...
    ```

    If you have other ROS 2 devices running in your LAN network make sure to provide a unique `ROS_DOMAIN_ID` (the default value is `ROS_DOMAIN_ID=0`) and select the right `SERIAL_PORT` depending on your ROSbot version (ROSbot 2 / ROSbot 2 PRO / ROSbot 2R). Note that if you run the demo example in a **simulation** then `SERIAL_PORT` is ignored, but it is necessary to define the `USE_SIM_TIME` variable to `True`.

4. Copy the changes to your ROSbot, eg. with [`rsync`](https://linux.die.net/man/1/rsync). Assuming your ROSbot IP address is `192.168.8.186`, just execute:

    ```bash
    rsync -vRr ./ husarion@192.168.8.186:/home/husarion/rosbot-docker
    ```

> **tip**
>
> You can keep your local folder (on a laptop) auto-synchronized with remote (on a ROSbot) with:
>
> ```bash
> ./sync_with_rosbot.sh 10.5.10.64
> ```
>
> where `10.5.10.64` is your ROSbot's IP address


## Choose your configuration
This docker-compose configuration allows you to run examples in a variety of ways. Set up your ROSbot and Rviz visualization.

1. **ROSbot with SLAM or AMCL (Simulation/Real Case)**

    Choose whether you want to launch simulation or bring up your robot hardware (column named `ROSbot or Gazebo`), whether you want to map the surrounding terrain (SLAM) or navigate it (AMCL) using a pre-built map (`Navigation Mode`), and finally specify the network configuration (`Network Configuration`).

    Choose one solution from each column:
    |                                                                                                                                                                                                                    ROSbot or Gazebo Bringup                                                                                                                                                                                                                     |                                                                                                                                                       Navigation Mode                                                                                                                                                       |                                                                                                                                                                                                                                   Network Configuration                                                                                                                                                                                                                                   |
    | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
    | `compose.rosbot.hardware.yaml` <br>*(this file allows you to run <br>the basic functionality of the robot.<br>If you choose this option run **all**<br> compose files from this tabel on ROSbot)*<br>***or***<br> `compose.rosbot.simulation.yaml` <br>*(Gazebo simulation, run **all** compose <br> files from this tabel on your PC<br>  with [Nvidia-docker](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html) drivers)* | `compose.rosbot.mapping.yaml` <br>*(creating a map of the environment <br> using slam-toolbox. <br>Remeber to [save the map]((https://github.com/husarion/rosbot-docker/tree/ros1/demo#saving-the-map-(slam-toolbox)))!)*<br>***or***<br> `compose.rosbot.localization.yaml` <br>*(AMCL based on a previously created map)* | You can use the default Docker network configuration <br>and then you don't need any additional file <br> *(Use this solution if you are running **simulation**)* <br> ***or*** <br> `compose.rosbot.lan.yaml`<br> *(LAN network)* <br> ***or*** <br>`compose.rosbot.vpn.yaml`<br>*(VPN network using [Husarnet](https://husarnet.com/). <br>This case requires additional [steps](https://github.com/husarion/rosbot-docker/tree/ros1/demo#controlling-rosbot-over-the-internet-(vpn)))* |

2. **Visualization: Rviz**

    Choose one solution from each column:

    |                                    Run Rviz node                                    |                                                                                                                                                                                      Set Network Configuration                                                                                                                                                                                       |
    | :---------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: |
    | `compose.rviz.yaml`<br>*(run **all** compose files from <br>this tabel on your PC)* | Use **the same** configuration <br>as in the table from step 1<br><br>**None**<br>***or*** <br>`compose.rviz.lan.yaml`<br>*(LAN network)* <br> ***or*** <br> `compose.rviz.vpn.yaml`<br>*(VPN network using [Husarnet](https://husarnet.com/). <br>This case requires additional [steps](https://github.com/husarion/rosbot-docker/tree/ros1-demo-devel/demo#controlling-rosbot-over-the-internet))* |


# Examples
## Mapping: Control ROSbot from RViz running on your laptop (slam-toolbox)
- case with LAN network:
  - On ROSbot:
      ```bash
      docker compose \
          -f compose.rosbot.hardware.yaml \
          -f compose.rosbot.mapping.yaml \
          -f compose.rosbot.lan.yaml \
          up
      ```

  - On laptop:
      ```bash
      xhost local:root
      docker compose -f compose.rviz.yaml -f compose.rviz.lan.yaml up
      ```
      Prepare map with Rviz2 using 2D Goal Pose.

- case with VPN network:
  
    Remember, this case requires additional [steps](https://github.com/husarion/rosbot-docker/tree/ros1/demo#controlling-rosbot-over-the-internet-(vpn)).

    - On ROSbot:
        ```bash
        docker compose \
            -f compose.rosbot.hardware.yaml \
            -f compose.rosbot.mapping.yaml \
            -f compose.rosbot.vpn.yaml \
            up
        ```
        
    - On laptop:
        ```bash
        xhost local:root
        docker compose -f compose.rviz.yaml -f compose.rviz.vpn.yaml up
        ```
        Prepare map with Rviz2 using 2D Goal Pose.

**If the map is ready, [save it](https://github.com/husarion/rosbot-docker/tree/ros1/demo#saving-the-map-(slam-toolbox)).**

## Autonomus localization: Control ROSbot from RViz running on your laptop (AMCL)
In order for the robot to be able to use the previously prepared map for localization and navigating, launch:

- On ROSbot:
    ```bash
    docker compose \
        -f compose.rosbot.hardware.yaml \
        -f compose.rosbot.localization.yaml \
        -f compose.rosbot.lan.yaml \
        up
    ```

- On laptop:
    Navigate to `/demo` folder and comment out the line of the `compose.rviz.yaml` file so that the rviz node uses the `rosbot_localization.rviz` configuration file. It should looks like this:
    ```yaml
    volumes: 
      - /tmp/.X11-unix:/tmp/.X11-unix:rw
      # - ./config/rosbot_mapping.rviz:/root/.rviz2/default.rviz
      - ./config/rosbot_localization.rviz:/root/.rviz2/default.rviz
    ```

    Next, run compose files:
    ```bash
    xhost local:root
    docker compose -f compose.rviz.yaml -f compose.rviz.lan.yaml up
    ```

**The above commands run an example on a lan network, but the same works for other types of connection.**

## Creating, Saving and Loading the Map with Gazebo (Simulation)

On your PC with [Nvidia-docker](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html) drivers launch:

```bash
xhost local:root
docker compose \
    -f compose.rosbot.simulation.yaml \
    -f compose.rosbot.mapping.yaml \
    -f compose.rviz.yaml \
    up
```
Prepare map with Rviz2 using 2D Goal Pose and [save the map](https://github.com/husarion/rosbot-docker/tree/ros1/demo#saving-the-map-(slam-toolbox)).

### Results:
[![Watch the video](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTW_xfemxP2RCJoKHXTmrEfozXNDK_svjRH8w&usqp=CAU)](
https://youtu.be/OiZTFYMlgis)

Next, see what the `compose.rviz.yaml` file should look like ([link](https://github.com/husarion/rosbot-docker/tree/ros1/demo#autonomus-localization:-control-rosbot-from-rviz-running-on-your-laptop-(amcl))) and launch `Navigation2` stack with `AMLC`:
```bash
xhost local:root
docker compose \
    -f compose.rosbot.simulation.yaml \
    -f compose.rosbot.localization.yaml \
    -f compose.rviz.yaml \
    up 
```

### Results:

[![Watch the video](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTW_xfemxP2RCJoKHXTmrEfozXNDK_svjRH8w&usqp=CAU)](https://www.youtube.com/watch?v=j_tRVuZiR18)

## Controlling ROSbot over the Internet (VPN)
1. Edit `demo/.env` file.
    
    Log in on your account at https://app.husarnet.com, create a new network, click the **[Add element]** button and copy the Join Code. Paste it in `.env` file as a value for `JOINCODE` environment variable. Do it both on ROSbot and on your PC i.e.:
    ```bash
    # for LAN examples you need to have unique ROS_DOMAIN_ID to avoid reading messages from other robots in the network
    ROS_DOMAIN_ID=228

    # for simulation example you need to use simulation time
    USE_SIM_TIME=False

    # SBC <> STM32 serial connection. Set:
    # /dev/ttyS1 for ROSbot 2
    # /dev/ttyS4 for ROSbot 2 PRO
    # /dev/ttyAMA0 for ROSbbot 2R
    SERIAL_PORT=/dev/ttyS4

    # Uncomment for compose.*.vpn.yaml files and paste your own Husarnet Join Code from app.husarnet.com here:
    JOINCODE=fc94:b01d:1803:8dd8:b293:5c7d:7639:932a/mVdwvA9oqtt5ahjmmGfF83
    ```

3. Generate DDS config files.

    In this example [Husarnet P2P VPN](https://husarnet.com/) is used for providing over the Internet connectivity. Default DDS discovery using multicasting doesn't work therefore. IPv6 addresses provided by Husarnet VPN need to be applied to a peer list in a `dds-config.xml` file. To do not copy those IPv6 addresses there is a simple utility script that does it for you. Everything you need to do is to launch it **ONLY ONCE** and copy **THE SAME** `secret/` folder to both devices:

    ```bash
    ./generate-vpn-config.sh
    ```

4. Copy the changes to your ROSbot, eg. with [`rsync`](https://linux.die.net/man/1/rsync). Assuming your ROSbot IP address is `192.168.8.186`, just execute:

    ```bash
    rsync -vRr ./ husarion@192.168.8.186:/home/husarion/rosbot-docker
    ```

5. Launch your compose files.

## Saving the Map (slam-toolbox)

If the map is ready, open a new terminal, navigate to `demo/` folder and execute:

- On ROSbot:
    ```bash
    ./map-save.sh
    ```

Your map has been saved in docker volume and is now in the maps/ folder.