# Demos



## Controlling ROSbot over LAN

1. Clone this repo both on ROSbot and on your PC and 
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

  If you have other ROS 2 devices running in your LAN network make sure to provide unique `ROS_DOMAIN_ID` (the default value is `ROS_DOMAIN_ID=0`)and select the right `SERIAL_PORT` depending on your ROSbot version (ROSbot 2 / ROSbot 2 PRO / ROSbot 2R).

### Launching on ROSbot

```
docker compose -f compose.rosbot.yaml -f compose.rosbot.lan.yaml up
```

### Launching on PC

```
xhost local:root
docker compose -f compose.rviz.yaml -f compose.rviz.lan.yaml up
```

## Controlling ROSbot over the Internet

1. Clone this repo both on ROSbot and on your PC and 
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

  In this example [Husarnet P2P VPN](https://husarnet.com/) is used for providing over the Internet connectivity. Default DDS discovery using multicasting doesn't work therefore. IPv6 addresses provided by Husarnet VPN need to be applied to a peer list in a `dds-config.xml` file. To do not copy those IPv6 addresses there is a simple utility script that does it for you. Everything you need to do is to launch it **ONLY ONCE** and copy **THE SAME** `secret/` folder to both devices.

### Launching on ROSbot

```
docker compose -f compose.rosbot.yaml -f compose.rosbot.vpn.yaml up
```

### Launching on PC

```
xhost local:root
docker compose -f compose.rviz.yaml -f compose.rviz.vpn.yaml up
```

