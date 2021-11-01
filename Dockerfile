# Building firmware.bin ... 

FROM --platform=linux/amd64 ubuntu:18.04 as stm32_fw

# ENV PIO_VERSION="5.1.0"

RUN apt update && apt install -y \
        python3 \
        python3-pip \
        git \
        tree

# https://docs.platformio.org/en/latest/core/installation.html#system-requirements
# RUN pip3 install -U platformio==${PIO_VERSION}
RUN pip3 install -U platformio

COPY .mbedignore ~/.platformio/packages/framework-mbed/features/.mbedignore

WORKDIR /app

RUN git clone https://github.com/husarion/rosbot-stm32-firmware.git

WORKDIR /app/rosbot-stm32-firmware

RUN git submodule update --init --recursive

RUN tree lib

RUN export LC_ALL=C.UTF-8 && \
    export LANG=C.UTF-8 && \
    pio run 

# RUN export LC_ALL=C.UTF-8 \
#     && export LANG=C.UTF-8 \
#     && cd rosbot-stm32-firmware  \
#     && pio project init -e core2_diff -O \
#         "build_flags= \
#         -I\$PROJECTSRC_DIR/TARGET_CORE2 \
#         -DPIO_FRAMEWORK_MBED_RTOS_PRESENT \
#         -DPIO_FRAMEWORK_EVENT_QUEUE_PRESENT \
#         -DMBED_BUILD_PROFILE_RELEASE \
#         -DROS_NOETIC_MSGS=0 \
#         -DKINEMATIC_TYPE=0" \
#     && pio project init -e core2_mec -O \
#         "build_flags= \
#         -I\$PROJECTSRC_DIR/TARGET_CORE2 \
#         -DPIO_FRAMEWORK_MBED_RTOS_PRESENT \
#         -DPIO_FRAMEWORK_EVENT_QUEUE_PRESENT \
#         -DMBED_BUILD_PROFILE_RELEASE \
#         -DROS_NOETIC_MSGS=0 \
#         -DKINEMATIC_TYPE=1" \
#     && pio run 


# Creating the ROS 2 image ...
FROM ros:melodic-ros-core

SHELL ["/bin/bash", "-c"]

RUN apt update && apt install -y python3-pip git
RUN python3 -m pip install --upgrade pyserial

# install ROS packages
RUN apt install -y ros-$ROS_DISTRO-rosserial-python \ 
        ros-$ROS_DISTRO-rosserial-server \
        ros-$ROS_DISTRO-rosserial-client \
        ros-$ROS_DISTRO-rosserial-msgs \
        ros-$ROS_DISTRO-robot-localization

# setup python GPIO
RUN git clone https://github.com/vsergeev/python-periphery.git --branch=v1.1.2 \
    && cd /python-periphery \
    && python3 setup.py install --record files.txt

# setup GPIO for tinkerboard
RUN git clone https://github.com/TinkerBoard/gpio_lib_python.git \
    && cd /gpio_lib_python \
    && python3 setup.py install --record files.txt

# clone and build CORE2 firmware installer
RUN git clone https://github.com/husarion/stm32loader.git \
    && cd stm32loader \
    && python3 setup.py install

WORKDIR /app

# copy firmware built in previous stage
COPY --from=stm32_fw /app/rosbot-stm32-firmware/.pio/build/core2_diff/firmware.bin /root/firmware_diff.bin
COPY --from=stm32_fw /app/rosbot-stm32-firmware/.pio/build/core2_mec/firmware.bin /root/firmware_mecanum.bin

# clone robot github repositories
RUN mkdir -p ros_ws/src \
    && git clone https://github.com/husarion/rosbot_description.git --branch=master ros_ws/src/rosbot_description \
    && git clone https://github.com/husarion/rosbot_ekf.git --branch=master ros_ws/src/rosbot_ekf 

# build ROS workspace
RUN cd ros_ws \
    && source /opt/ros/$ROS_DISTRO/setup.bash \
    && catkin_make -DCATKIN_ENABLE_TESTING=0 -DCMAKE_BUILD_TYPE=Release

# clear ubuntu packages
RUN apt clean && \
    rm -rf /var/lib/apt/lists/*

# copy scripts
COPY ./flash_firmware_diff.sh .
COPY ./flash_firmware_mecanum.sh .
COPY ./ros_entrypoint.sh /

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]