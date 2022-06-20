#!/usr/bin/python3

import RPi.GPIO as GPIO
import sh 
import time
import sys
import argparse

parser = argparse.ArgumentParser(description='Flashing the firmware on STM32 microcontroller in ROSbot')
parser.add_argument("file", nargs='?', default="/root/firmware_diff.bin", help="Path to a firmware file. Default = /root/firmware_diff.bin")
args = parser.parse_args()

print("=====================================================")
print("Flashing STM32 with: ", args.file, "binary")
print("=====================================================")

boot0_pin=11    # GPIO 17
reset_pin=12    # GPIO 18

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
    sh.stm32flash("/dev/ttyAMA0", "-u", _out=sys.stdout)
    time.sleep(0.2)

    print("*********************")
    print("Disable the flash read-protection")
    sh.stm32flash("/dev/ttyAMA0", "-k", _out=sys.stdout) 
    # sh.stm32flash(w="/root/firmware_diff.bin", b="115200", v="/dev/ttyAMA0")
    time.sleep(0.2)

    # stm32flash -w /root/firmware_diff.bin -b 115200 -v /dev/ttyAMA0
    print("*********************")
    print("Flashing the firmware")
    sh.stm32flash("/dev/ttyAMA0", "-v", w=args.file, b="115200", _out=sys.stdout) 
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
