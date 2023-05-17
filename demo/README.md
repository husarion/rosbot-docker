# rosbot-sensors
Visualization for ROSbot 2R, ROSbot 2 PRO and ROSbot 2.0 sensors.

# Quick Start
## PC
Clone the repository:
```
git clone https://github.com/husarion/rosbot-docker
cd rosbot-docker
```

In `.env` file you can change the lidar baudrate and enable the mecanum controller.
In `net.env` file you can change network configuration.

Sync workspace with ROSbot
```
./sync_with_rosbot.sh <ROSbot_ip>
```

Open web browser and go to `<ROSbot_ip>:8080` website (Chrome is recommended).

## ROSbot
In the ROSbot's shell execute (in the `/home/husarion/rosbot-docker/demo directory`)
```
docker compose -f compose.yaml up
```

# Demo
Now reload the Foxglove website in your PC. You should see the Foxglove application. Click on left top button `Data source`, click the plus `new connection` -> `Open connection` and you should see `WebSocket URL` set to `ws://<ROSbot_ip>:9090` > `Open`
![foxglove_sensors](.docs/foxglove_connect.gif)