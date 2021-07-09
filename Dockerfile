FROM ubuntu:20.04 as stm32_fw

RUN apt update && apt install -y \
    python3 \
    python3-pip \
    git

RUN python3 -m pip install --upgrade pyserial

# https://docs.platformio.org/en/latest/core/installation.html#system-requirements
RUN pip install -U platformio

COPY .mbedignore ~/.platformio/packages/framework-mbed/features/.mbedignore

WORKDIR /app

RUN git clone https://github.com/husarion/rosbot-stm32-firmware.git --branch=main && \
    cd rosbot-stm32-firmware && \
    git submodule update --init --recursive && \
    pio run


FROM ros:melodic

SHELL ["/bin/bash", "-c"]

RUN apt update && apt install -y \
    python3-pip

RUN python3 -m pip install --upgrade pyserial

RUN git clone https://github.com/husarion/stm32loader.git && \
    cd stm32loader && \
    python3 setup.py install

WORKDIR /app

COPY --from=stm32_fw /app/rosbot-stm32-firmware/.pio/build/core2/firmware.bin .

RUN mkdir -p ros_ws/src && \
    git clone https://github.com/husarion/rosbot_description.git --branch=master ros_ws/src/rosbot_description

RUN cd ros_ws/ && \
    source /opt/ros/melodic/setup.bash && \
    catkin_make -DCATKIN_ENABLE_TESTING=0 -DCMAKE_BUILD_TYPE=Release

COPY ./flash_firmware.sh .
COPY ./ros_entrypoint.sh /

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
    