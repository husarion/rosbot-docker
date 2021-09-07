# Building firmware.bin ... 

FROM --platform=linux/amd64 ubuntu:18.04 as stm32_fw

RUN apt update && apt install -y \
    python3 \
    python3-pip \
    git

# https://docs.platformio.org/en/latest/core/installation.html#system-requirements
RUN pip3 install -U platformio

WORKDIR /app

RUN git clone https://github.com/husarion/rosbot-stm32-firmware.git --branch=main --depth 1

RUN export LC_ALL=C.UTF-8 && \
    export LANG=C.UTF-8 && \
    cd rosbot-stm32-firmware && \
    git submodule update --init --recursive && \
    pio run 

# Creating the ROS image ...

FROM ros:melodic

SHELL ["/bin/bash", "-c"]

RUN apt update && apt install -y \
    python3-pip

RUN python3 -m pip install --upgrade pyserial

RUN apt install -y ros-melodic-xacro \ 
    ros-melodic-rosserial-python \ 
    ros-melodic-rosserial-server \
    ros-melodic-rosserial-client \
    ros-melodic-rosserial-msgs \
    ros-melodic-robot-localization \
    ros-melodic-robot-state-publisher

RUN cd ~/ && git clone https://github.com/vsergeev/python-periphery.git && \
    cd ~/python-periphery && git checkout v1.1.2 &&\
    python3 setup.py install --record files.txt

RUN cd ~/ && git clone https://github.com/TinkerBoard/gpio_lib_python.git &&\
    cd ~/gpio_lib_python && python3 setup.py install --record files.txt

RUN git clone https://github.com/husarion/stm32loader.git && \
    cd stm32loader && \
    python3 setup.py install

WORKDIR /app

COPY --from=stm32_fw /app/rosbot-stm32-firmware/.pio/build/core2_diff/firmware.bin /root

RUN mv /root/firmware.bin /root/firmware_diff.bin

COPY --from=stm32_fw /app/rosbot-stm32-firmware/.pio/build/core2_mec/firmware.bin /root

RUN mv /root/firmware.bin /root/firmware_mecanum.bin

RUN mkdir -p ros_ws/src && \
    git clone https://github.com/husarion/rosbot_description.git --branch=master ros_ws/src/rosbot_description && \
    git clone https://github.com/husarion/rosbot_ekf.git --branch=master ros_ws/src/rosbot_ekf 

RUN cd ros_ws/ && \
    source /opt/ros/melodic/setup.bash && \
    catkin_make -DCATKIN_ENABLE_TESTING=0 -DCMAKE_BUILD_TYPE=Release

COPY ./flash_firmware_diff.sh .
COPY ./flash_firmware_mecanum.sh .
COPY ./ros_entrypoint.sh /

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
