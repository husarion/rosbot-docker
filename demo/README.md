# Demos

## Controlling ROSbot over LAN

1. Clone this repo on your PC:

    ```bash
    git clone https://github.com/husarion/rosbot-docker.git
    cd rosbot-docker/
    ```

2. modify `demo/.env` file:

    ```bash
    # for LAN examples you need to have unique ROS_DOMAIN_ID to avoid reading messages from other robots in the network
    ROS_DOMAIN_ID=228
    
    # SBC <> STM32 serial connection. Set:
    # /dev/ttyS1 for ROSbot 2
    # /dev/ttyS4 for ROSbot 2 PRO
    # /dev/ttyAMA0 for ROSbbot 2R
    SERIAL_PORT=/dev/ttyAMA0
    ```

    If you have other ROS 2 devices running in your LAN network make sure to provide unique `ROS_DOMAIN_ID` (the default value is `ROS_DOMAIN_ID=0`) and select the right `SERIAL_PORT` depending on your ROSbot version (ROSbot 2 / ROSbot 2 PRO / ROSbot 2R).

3. Copy the changes to your ROSbot, eg. with [`rsync`](https://linux.die.net/man/1/rsync). Assuming your ROSbot IP address is `192.168.8.186`, just execute:

    ```bash
    rsync -vRr ./ husarion@192.168.8.186:/home/husarion/rosbot-docker
    ```

### Launching on PC

```bash
xhost local:root
docker compose -f compose.rviz.yaml -f compose.rviz.lan.yaml up
```

### Launching on ROSbot

SSH to ROSbot (assuming your ROSbot IP address is `192.168.8.186`):

```bash
ssh husarion@192.168.8.186
```

Go to the `/home/husarion/rosbot-docker/demo` folder and run:

```bash
docker compose -f compose.rosbot.yaml -f compose.rosbot.lan.yaml up
```

## Controlling ROSbot over the Internet

1. Clone this repo on your PC:

    ```bash
    git clone https://github.com/husarion/rosbot-docker.git
    cd rosbot-docker/
    ```

2. modify `demo/.env` file:

    ```bash
    # SBC <> STM32 serial connection. Set:
    # /dev/ttyS1 for ROSbot 2
    # /dev/ttyS4 for ROSbot 2 PRO
    # /dev/ttyAMA0 for ROSbbot 2R
    SERIAL_PORT=/dev/ttyAMA0
  
    # Uncomment for compose.*.husarnet.yaml files and paste your own Husarnet Join Code from app.husarnet.com here:
    JOINCODE=fc94:b01d:1803:8dd8:b293:5c7d:7639:932a/xxxxxxxxxxxxxxxxxxxxxx
    ```

    Select the right `SERIAL_PORT` depending on your ROSbot version (ROSbot 2 / ROSbot 2 PRO / ROSbot 2R). Log in on your account at https://app.husarnet.com, create a new network, click the **[Add element]** button and copy the Join Code. Paste it in `.env` file as a value for `JOINCODE` environment variable. Do it both on ROSbot and on your PC

3. Generate DDS config files.

    In this example [Husarnet P2P VPN](https://husarnet.com/) is used for providing over the Internet connectivity. Default DDS discovery using multicasting doesn't work therefore. IPv6 addresses provided by Husarnet VPN need to be applied to a peer list in a `dds-config.xml` file. To do not copy those IPv6 addresses there is a simple utility script that does it for you. Everything you need to do is to launch it **ONLY ONCE** and copy **THE SAME** `secret/` folder to both devices:

    ```
    ./generate-vpn-config.sh
    ```

4. Copy the changes to your ROSbot, eg. with [`rsync`](https://linux.die.net/man/1/rsync). Assuming your ROSbot IP address is `192.168.8.186`, just execute:

    ```bash
    rsync -vRr ./ husarion@192.168.8.186:/home/husarion/rosbot-docker
    ```

### Launching on PC

```bash
xhost local:root
docker compose -f compose.rviz.yaml -f compose.rviz.vpn.yaml up
```

### Launching on ROSbot

SSH to ROSbot (Assuming your ROSbot IP address is `192.168.8.186`):

```bash
ssh husarion@192.168.8.186
```

Go to the `/home/husarion/rosbot-docker/demo` folder and run:

```bash
docker compose -f compose.rosbot.yaml -f compose.rosbot.vpn.yaml up
```

