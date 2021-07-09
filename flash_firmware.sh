#!/bin/bash
sudo stm32loader -c upboard -u -W
sleep 1
sudo stm32loader -c upboard -e -w -v ./firmware.bin
