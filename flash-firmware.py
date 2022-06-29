#!/usr/bin/python3

import sh 
import time
import sys
import argparse

def rpi_flash_firmware():
    
    import RPi.GPIO as GPIO

    boot0_pin=11    # GPIO 17
    reset_pin=12    # GPIO 18
    port = "/dev/ttyAMA0"

    try:
        GPIO.setmode(GPIO.BOARD)
        GPIO.setup(boot0_pin, GPIO.OUT)
        GPIO.setup(reset_pin, GPIO.OUT)

        print("*********************")
        print("enter bootloader mode\r\n")
        GPIO.output(boot0_pin, GPIO.HIGH)
        GPIO.output(reset_pin, GPIO.HIGH)
        time.sleep(0.2)
        GPIO.output(reset_pin, GPIO.LOW)
        time.sleep(0.2)

        print("*********************")
        print("Disable the flash write-protection")
        sh.stm32flash(port, "-u", _out=sys.stdout)
        time.sleep(0.2)

        print("*********************")
        print("Disable the flash read-protection")
        sh.stm32flash(port, "-k", _out=sys.stdout) 
        # sh.stm32flash(w="/root/firmware_diff.bin", b="115200", v=port)
        time.sleep(0.2)

        # stm32flash -w /root/firmware_diff.bin -b 115200 -v /dev/ttyAMA0
        print("*********************")
        print("Flashing the firmware")
        sh.stm32flash(port, "-v", w=args.file, b="115200", _out=sys.stdout) 
        time.sleep(0.2)

        print("*********************")
        print("exit bootloader mode")
        GPIO.output(boot0_pin, GPIO.LOW)
        GPIO.output(reset_pin, GPIO.HIGH)
        time.sleep(0.2)
        GPIO.output(reset_pin, GPIO.LOW)
        # GPIO.cleanup()
    finally:
        print("*********************")
        print('done') 
        GPIO.cleanup()


def upboard_flash_firmware():
    boot0_pin=11    # GPIO 17
    reset_pin=12    # GPIO 18
    port = "/dev/ttyS4"

    # setup pins
    try:
        sh.bash("-c", f"echo {boot0_pin} > /sys/class/gpio/export")
        sh.bash("-c", f"echo out > /sys/class/gpio/gpio{boot0_pin}/direction")

        sh.bash("-c", f"echo {reset_pin} > /sys/class/gpio/export")
        sh.bash("-c", f"echo out > /sys/class/gpio/gpio{reset_pin}/direction")

    except:
        print("Pin setup\n")
        sh.bash("-c", f"echo 0 > /sys/class/gpio/gpio{boot0_pin}/value")
        sh.bash("-c", f"echo 0 > /sys/class/gpio/gpio{reset_pin}/value")
        time.sleep(0.5)

    print("*********************")
    print("enter bootloader mode\r\n")

    sh.bash("-c", f"echo 1 > /sys/class/gpio/gpio{boot0_pin}/value")
    sh.bash("-c", f"echo 1 > /sys/class/gpio/gpio{reset_pin}/value")
    time.sleep(0.2)
    sh.bash("-c", f"echo 0 > /sys/class/gpio/gpio{reset_pin}/value")
    time.sleep(0.2)

    print("*********************")
    print("Disable the flash write-protection")
    sh.stm32flash(port, "-u", _out=sys.stdout)
    time.sleep(0.2)

    print("*********************")
    print("Disable the flash read-protection")
    sh.stm32flash(port, "-k", _out=sys.stdout) 
    time.sleep(0.2)

    print("*********************")
    print("Flashing the firmware")
    sh.stm32flash(port, "-v", w=args.file, b="115200", _out=sys.stdout) 
    time.sleep(0.2)

    print("*********************")
    print("exit bootloader mode")
    sh.bash("-c", f"echo 0 > /sys/class/gpio/gpio{boot0_pin}/value")
    sh.bash("-c", f"echo 1 > /sys/class/gpio/gpio{reset_pin}/value")
    time.sleep(0.2)
    sh.bash("-c", f"echo 0 > /sys/class/gpio/gpio{reset_pin}/value")

    return


def thinker_flash_firmware():
    return


parser = argparse.ArgumentParser(description='Flashing the firmware on STM32 microcontroller in ROSbot')
parser.add_argument("file", nargs='?', default="/root/firmware_diff.bin", help="Path to a firmware file. Default = /root/firmware_diff.bin")
args = parser.parse_args()

sys_arch = sh.uname('-m')

print("=====================================================")
print("Flashing STM32 with: ", args.file, "binary")
print("=====================================================\n")
print(f"System architecture: {sys_arch}")

if sys_arch.stdout == b'x86_64\n':
    print("Device: Upboard\n")
    upboard_flash_firmware()
    
    
elif sys_arch.stdout == b'armv7l\n':
    print("Device: Tinker\n")
    
    
elif sys_arch.stdout == b'aarch64\n':
    print("Device: RPi\n")
    rpi_flash_firmware()
    
else:
    print("Unknown device...")