#!/usr/bin/python3

import RPi.GPIO as GPIO
import sh 
import time

boot0_pin=11    # GPIO 17
reset_pin=12    # GPIO 18

GPIO.setmode(GPIO.BOARD)
GPIO.setup(boot0_pin, GPIO.OUT)
GPIO.setup(reset_pin, GPIO.OUT)

# enter bootloader mode
GPIO.output(boot0_pin, GPIO.HIGH)
GPIO.output(reset_pin, GPIO.HIGH)
time.sleep(0.2)
GPIO.output(reset_pin, GPIO.LOW)

# /stm32flash -w /root/firmware_diff.bin -b 115200 -v /dev/ttyAMA0
sh.stm32flash(w="/root/firmware_diff.bin", b="115200", v="/dev/ttyAMA0") 

# exit bootloader mode
GPIO.output(boot0_pin, GPIO.LOW)
GPIO.output(reset_pin, GPIO.HIGH)
time.sleep(0.2)
GPIO.output(reset_pin, GPIO.LOW)