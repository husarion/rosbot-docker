# rosbot-teleop
Teleop twist driving demo for ROSbot 2R, ROSbot 2 PRO and ROSbot 2.0.

# Quick Start
## Real Robot
### On PC
Clone the repository:
```
git clone https://github.com/husarion/rosbot-docker
cd rosbot-docker
```

In the `.env` file, you have the option to modify the lidar baudrate and enable the mecanum controller if necessary.
In the `net.env` file you can change network configuration.

Sync workspace with ROSbot
```
./sync_with_rosbot.sh <ROSbot_ip>
```

### On ROSbot
In the ROSbot's shell execute (in the `/home/husarion/rosbot-docker/demo` directory)
```
docker compose -f compose.yaml up
```

## Simulation
If you don't have Nvidia GPU replace `*gpu-config` with `*cpu-config` in `rosbot` service inside `compose.simulation.yaml` file.

In the PC's shell execute (in the `demo/` directory):
```
xhost local:root
docker compose -f compose.simulation.yaml up
```

## Drive the ROSbot
In another shell (if you use hardware use another ROSbot's shell) enter the docker container:
```
docker exec -it demo-rosbot-1 bash
```
and run inside `teleop_twist_keyboard` to drive the ROSbot
```
ros2 run teleop_twist_keyboard teleop_twist_keyboard
```

With keys `i`, `j`, `l`, `,` you can drive forward, counter clockwise, clockwise and backwards. If you are using macanum wheels (see `demo/.env` file) hold `Shift` key that way the ROSbot goes left and right with `j` and `l` keys instead rotates.