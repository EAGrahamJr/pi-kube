#!/usr/bin/env bash
# red led
# activity led
if [ "$1" = "on" ]; then
    sudo sh -c 'echo input > /sys/class/leds/led1/trigger'
    sudo sh -c 'echo mmc0 > /sys/class/leds/led0/trigger'
else
    sudo sh -c 'echo 0 > /sys/class/leds/led1/brightness'
    sudo sh -c 'echo 0 > /sys/class/leds/led0/brightness'
fi
