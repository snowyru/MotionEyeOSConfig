#!/bin/bash
# Place into motioneyeos /data/etc/
GPIO=21 # Change this to your output pin
test -e /sys/class/gpio/gpio$GPIO || (echo $GPIO > /sys/class/gpio/export \
&& echo out > /sys/class/gpio/gpio$GPIO/direction) # Set pin as output

while true; do
    time=$(date +%T) # Get the current time
    hour=${time%%:*} # Extract the hour
    if (( 6 <= 10#$hour && 10#$hour < 20 )); then
        echo 1 > /sys/class/gpio/gpio$GPIO/value # Set pin to ground
    else
        echo 0 > /sys/class/gpio/gpio$GPIO/value # Set pin to 3.3V
    fi
    sleep 300 # Wait for 300 seconds (5 minutes)
done
