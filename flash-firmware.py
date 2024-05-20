#!/usr/bin/python3

# Copyright 2023 Husarion
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import sh
import time
import sys
import argparse
from periphery import GPIO


class FirmwareFlasher:
    def __init__(self, binary_file):
        self.binary_file = binary_file
        sys_arch = str(sh.uname("-m")).strip()

        self.max_approach_no = 1

        print(f"System architecture: {sys_arch}")

        if sys_arch == "armv7l":
            # Setups ThinkerBoard pins
            print("Device: ThinkerBoard\n")
            self.port = "/dev/ttyS1"
            boot0_pin_no = 164
            reset_pin_no = 184

        elif sys_arch == "x86_64":
            # Setups UpBoard pins
            print("Device: UpBoard\n")
            self.port = "/dev/ttyS4"
            boot0_pin_no = 17
            reset_pin_no = 18

        elif sys_arch == "aarch64":
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

    def try_flash_operation(self, operation_name, flash_args):
        self.enter_bootloader_mode()
        
        try:
            if operation_name == "Flashing":
                sh.stm32flash(self.port, *flash_args, _out=sys.stdout)
                time.sleep(0.2)
                print("Success! The robot firmware has been uploaded.")
            else:                    
                sh.stm32flash(self.port, *flash_args)
                time.sleep(0.2)
        except Exception as e:
            stderr = e.stderr.decode('utf-8')
            if stderr:
                print(f"ERROR {operation_name} went wrong: {stderr}")
            
        self.exit_bootloader_mode()


    def flash_firmware(self):
        # Disable the flash write-protection
        self.try_flash_operation("Write-UnProtection", ["-u"])

        # Disable the flash read-protection
        self.try_flash_operation("Read-UnProtection", ["-k"])

        # Flashing the firmware
        flash_args = ["-v", "-w", self.binary_file, "-b", "115200"]
        self.try_flash_operation("Flashing", flash_args)


def main():
    parser = argparse.ArgumentParser(
        description="Flashing the firmware on STM32 microcontroller in ROSbot"
    )

    parser.add_argument(
        "file",
        nargs="?",
        default="/root/firmware_diff.bin",
        help="Path to a firmware file. Default = /root/firmware.bin",
    )

    binary_file = parser.parse_args().file

    flasher = FirmwareFlasher(binary_file)
    flasher.flash_firmware()


if __name__ == "__main__":
    main()
