# Creating the ROS image ...

FROM ros:melodic

SHELL ["/bin/bash", "-c"]

RUN apt update && apt install -y \
    python3-pip

RUN python3 -m pip install --upgrade pyserial

RUN apt install -y ros-melodic-xacro ros-melodic-rosserial-python

RUN cd ~/ && git clone https://github.com/vsergeev/python-periphery.git && \
    cd ~/python-periphery && git checkout v1.1.2 &&\
    python3 setup.py install --record files.txt

RUN cd ~/ && git clone https://github.com/TinkerBoard/gpio_lib_python.git &&\
    cd ~/gpio_lib_python && python3 setup.py install --record files.txt

RUN git clone https://github.com/husarion/stm32loader.git && \
    cd stm32loader && \
    python3 setup.py install

WORKDIR /app

COPY --from=husarion/rosbot-firmware /app/.pio/build/core2/firmware.bin .

RUN mkdir -p ros_ws/src && \
    git clone https://github.com/husarion/rosbot_description.git --branch=master ros_ws/src/rosbot_description

RUN cd ros_ws/ && \
    source /opt/ros/melodic/setup.bash && \
    catkin_make -DCATKIN_ENABLE_TESTING=0 -DCMAKE_BUILD_TYPE=Release

COPY ./flash_firmware.sh .
COPY ./ros_entrypoint.sh /

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
