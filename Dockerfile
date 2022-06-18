
## ============================ STM32FLASH =================================
FROM ubuntu:20.04 AS stm32flash_builder

# official releases are only for intel archs, so we need to build stm32flash from sources
RUN apt-get update && apt-get install -y \
        git \
        build-essential && \
    git clone https://github.com/stm32duino/stm32flash.git && \
    cd stm32flash/ && \
    make all

## =========================== STM32 firmware===============================
# FROM --platform=linux/amd64 ubuntu:18.04 as stm32_firmware_builder
# TODO: wget from releases instead
FROM ubuntu:20.04 AS stm32_firmware_builder

SHELL ["/bin/bash", "-c"]

# ENV PIO_VERSION="5.1.0"
RUN apt update && apt install -y \
        python3 \
        python3-pip \
        git \
        tree

# https://docs.platformio.org/en/latest/core/installation.html#system-requirements
# RUN pip3 install -U platformio==${PIO_VERSION}
RUN pip3 install -U platformio

RUN git clone https://github.com/husarion/rosbot-stm32-firmware.git && \
    mkdir -p ~/.platformio/packages/framework-mbed/features/ && \
    cp rosbot-stm32-firmware/.mbedignore ~/.platformio/packages/framework-mbed/features/.mbedignore

WORKDIR /rosbot-stm32-firmware

RUN git submodule update --init --recursive

RUN export LC_ALL=C.UTF-8 && \
    export LANG=C.UTF-8 && \
    pio project init -e core2_diff -O \
        "build_flags= \
        -I\$PROJECTSRC_DIR/TARGET_CORE2 \
        -DPIO_FRAMEWORK_MBED_RTOS_PRESENT \
        -DPIO_FRAMEWORK_EVENT_QUEUE_PRESENT \
        -DMBED_BUILD_PROFILE_RELEASE \
        -DROS_NOETIC_MSGS=0 \
        -DKINEMATIC_TYPE=0" && \
    pio project init -e core2_mec -O \
        "build_flags= \
        -I\$PROJECTSRC_DIR/TARGET_CORE2 \
        -DPIO_FRAMEWORK_MBED_RTOS_PRESENT \
        -DPIO_FRAMEWORK_EVENT_QUEUE_PRESENT \
        -DMBED_BUILD_PROFILE_RELEASE \
        -DROS_NOETIC_MSGS=0 \
        -DKINEMATIC_TYPE=1" && \
    pio run 

## =========================== ROS 2 image ===============================
FROM ros:melodic-ros-core

SHELL ["/bin/bash", "-c"]

RUN apt update && apt install -y python3-pip git
RUN python3 -m pip install --upgrade pyserial

# install ROS packages
RUN apt install -y ros-$ROS_DISTRO-rosserial-python \ 
        ros-$ROS_DISTRO-rosserial-server \
        ros-$ROS_DISTRO-rosserial-client \
        ros-$ROS_DISTRO-rosserial-msgs \
        ros-$ROS_DISTRO-robot-localization && \
    pip3 install RPi.GPIO && \
    pip3 install sh && \
    pip3 install pyserial && \
    # clear ubuntu packages
    apt clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# clone robot github repositories
RUN mkdir -p ros_ws/src \
    && git clone https://github.com/husarion/rosbot_description.git --branch=master ros_ws/src/rosbot_description \
    && git clone https://github.com/husarion/rosbot_ekf.git --branch=master ros_ws/src/rosbot_ekf 

# build ROS workspace
RUN cd ros_ws \
    && source /opt/ros/$ROS_DISTRO/setup.bash \
    && catkin_make -DCATKIN_ENABLE_TESTING=0 -DCMAKE_BUILD_TYPE=Release

# copy firmware built in previous stage
COPY --from=stm32_firmware_builder /rosbot-stm32-firmware/.pio/build/core2_diff/firmware.bin /root/firmware_diff.bin
COPY --from=stm32_firmware_builder /rosbot-stm32-firmware/.pio/build/core2_mec/firmware.bin /root/firmware_mecanum.bin
COPY --from=stm32flash_builder /stm32flash/stm32flash /usr/bin/stm32flash

# copy scripts
COPY ./flash-firmware.py /
COPY ./ros_entrypoint.sh /


ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]