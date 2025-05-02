#!/bin/bash
# Place into motioneyeos /data/etc/
GPIO=21 # Change this to your output pin
test -e /sys/class/gpio/gpio$GPIO || (echo $GPIO > /sys/class/gpio/export \
&& echo out > /sys/class/gpio/gpio$GPIO/direction) # Set pin as output

# Latitude and Longitude for Cape Town
LAT="-33.9249"  # Cape Town Latitude
LON="18.4241"   # Cape Town Longitude

get_sun_times() {
    # Fetch the sunrise and sunset times using the Sunrise-Sunset API
    response=$(curl -s "https://api.sunrise-sunset.org/json?lat=$LAT&lng=$LON&formatted=0")
    sunrise=$(echo "$response" | jq -r .results.sunrise) # Sunrise time in UTC
    sunset=$(echo "$response" | jq -r .results.sunset)   # Sunset time in UTC

    # Convert sunrise/sunset to local time (assuming system is in local time)
    sunrise_local=$(date -d "$sunrise" +%H:%M)
    sunset_local=$(date -d "$sunset" +%H:%M)
}

while true; do
    # Update sunrise and sunset times daily at midnight
    current_time=$(date +%H:%M)
    if [[ "$current_time" == "00:00" ]]; then
        get_sun_times
    fi

    hour_minute=$(date +%H:%M)

    # Compare current time with sunrise and sunset
    if [[ "$hour_minute" > "$sunrise_local" && "$hour_minute" < "$sunset_local" ]]; then
        echo 0 > /sys/class/gpio/gpio$GPIO/value # Turn night vision off (daytime)
    else
        echo 1 > /sys/class/gpio/gpio$GPIO/value # Turn night vision on (nighttime)
    fi

    sleep 300 # Wait for 300 seconds (5 minutes)
done
