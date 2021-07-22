#!/bin/bash
sys_arch=$(uname -m)
echo $1
if [ $1 -gt 0 ]; then
    echo $sys_arch
    case $sys_arch in
    x86_64)
        sudo stm32loader -c upboard -u -W
        sleep 1
        sudo stm32loader -c upboard -e -w -v ./firmware.bin
        ;;
    armv7l)
        sudo stm32loader -c tinker -u -W
        sleep 1
        sudo stm32loader -c tinker -e -w -v ~/firmware.bin
        ;;
    esac
fi
