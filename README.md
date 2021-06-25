# rosbot-docker
Docker Image for ROS Melodic Node providing interface for STM32 firmware over ROS-serial.

This image should also flash the appriopriate version of [ROSbot 2.0 STM32 firmware](https://github.com/husarion/rosbot-stm32-firmware) - to do not reflash the STM32 already flashed with the proper version of the firmware, the solutions mentioned below are fine:

- **Easier One** - define `ENV AUTO_STM32_FLASH=1` environmental variable in DockerHub. Then to disable auto-firmware upgrade all you need to do is run the container the following way: `docker run .... --env AUTO_STM32_FLASH=0 ... rosbot-docker`
- **Harder One** - add another ROS service to `rosbot-stm32-firmware`, like `get-version` and the firmware will being reflashed only if the firmware version is wrong or after timeout.

To not overcomplicate the problem, **Easier One** option is fine.
