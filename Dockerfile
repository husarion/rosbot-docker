FROM ubuntu:20.04

RUN apt update && apt install -y \
    python3 \
    python3-pip \
    git

# https://docs.platformio.org/en/latest/core/installation.html#system-requirements
RUN pip install -U platformio

COPY .mbedignore ~/.platformio/packages/framework-mbed/features/.mbedignore

WORKDIR /app

RUN git clone https://github.com/husarion/rosbot-stm32-firmware.git --branch=main && \
    cd rosbot-stm32-firmware && \
    git submodule update --init --recursive && \
    pio run





    