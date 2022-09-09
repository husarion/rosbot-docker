#!/usr/bin/python3

import sh
import time
import sys
import argparse
from periphery import GPIO


class FirmwareFlasher:
    def __init__(self, sys_arch, binary_file):

        self.binary_file = binary_file
        self.sys_arch = sys_arch

        self.max_approach_no = 5

        print(f"System architecture: {self.sys_arch}")

        if self.sys_arch.stdout == b'armv7l\n':
            # Setups ThinkerBoard pins
            print("Device: ThinkerBoard\n")
            self.port = "/dev/ttyS1"
            boot0_pin_no = 164
            reset_pin_no = 184


        elif self.sys_arch.stdout == b'x86_64\n':
            # Setups UpBoard pins
            print("Device: UpBoard\n")
            self.port = "/dev/ttyS4"
            boot0_pin_no = 17
            reset_pin_no = 18

        elif self.sys_arch.stdout == b'aarch64\n':
            # Setups RPi pins
            print("Device: RPi\n")
            self.port = "/dev/ttyAMA0"
            boot0_pin_no = 17
            reset_pin_no = 18

        else:
            print("Unknown device...")

        self.boot0_pin = GPIO(boot0_pin_no, "out")
        self.reset_pin = GPIO(reset_pin_no, "out")


    def enter_bootloader_mode(self):

        self.boot0_pin.write(True)
        self.reset_pin.write(True)
        time.sleep(0.2)
        self.reset_pin.write(False)
        time.sleep(0.2)


    def exit_bootloader_mode(self):

        self.boot0_pin.write(False)
        self.reset_pin.write(True)
        time.sleep(0.2)
        self.reset_pin.write(False)
        time.sleep(0.2)


    def flash_firmware(self):

        self.enter_bootloader_mode()

        # Flashing the firmware
        succes_no = 0
        for i in range(self.max_approach_no):
            try:
                if succes_no == 0:
                    # Disable the flash write-protection
                    sh.stm32flash(self.port, "-u", _out=sys.stdout)
                    time.sleep(0.2)
                    succes_no += 1

                if succes_no == 1:
                    # Disable the flash read-protection
                    sh.stm32flash(self.port, "-k", _out=sys.stdout)
                    time.sleep(0.2)
                    succes_no += 1

                if succes_no == 2:
                    # Flashing the firmware
                    sh.stm32flash(self.port, "-v", w=self.binary_file, b="115200", _out=sys.stdout)
                    time.sleep(0.2)
                    break
            except:
                pass

        else:
            print('ERROR! Something goes wrong. Try again.')


        self.exit_bootloader_mode()



def main():

    parser = argparse.ArgumentParser(
        description='Flashing the firmware on STM32 microcontroller in ROSbot')

    parser.add_argument(
        "file",
        nargs='?',
        default="/root/firmware.bin",
        help="Path to a firmware file. Default = /root/firmware.bin")

    binary_file = parser.parse_args().file
    sys_arch = sh.uname('-m')

    flasher = FirmwareFlasher(sys_arch, binary_file)
    flasher.flash_firmware()
    print("Done.")


if __name__ == "__main__":
    main()