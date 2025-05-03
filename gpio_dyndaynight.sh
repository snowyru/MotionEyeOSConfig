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

    # Preprocess the dates: Replace 'T' with a space and remove '+00:00'
    sunrise_clean=$(echo "$sunrise" | sed 's/T/ /' | sed 's/+00:00//')
    sunset_clean=$(echo "$sunset" | sed 's/T/ /' | sed 's/+00:00//')

    # Convert sunrise/sunset to local time (assuming system is in local time)
    sunrise_local=$(TZ=Africa/Johannesburg date -d "$sunrise_clean" +%H:%M)
    sunset_local=$(TZ=Africa/Johannesburg date -d "$sunset_clean" +%H:%M)

    # Debugging: Log fetched and converted times
    echo "DEBUG: Sunrise (UTC): $sunrise, Sunset (UTC): $sunset" >> /data/etc/gpio_dyndaynight.log
    echo "DEBUG: Cleaned Sunrise: $sunrise_clean, Cleaned Sunset: $sunset_clean" >> /data/etc/gpio_dyndaynight.log
    echo "DEBUG: Sunrise (Local): $sunrise_local, Sunset (Local): $sunset_local" >> /data/etc/gpio_dyndaynight.log
}

# Fetch sunrise and sunset times initially
get_sun_times

while true; do
    # Update sunrise and sunset times daily at midnight
    current_time=$(date +%H:%M)
    if [[ "$current_time" == "00:00" ]]; then
        get_sun_times
    fi

    # Current hour and minute
    hour_minute=$(date +%H:%M)

    # Debugging: Log the current time
    echo "DEBUG: Current time (Local): $hour_minute" >> /data/etc/gpio_dyndaynight.log

    # Compare current time with sunrise and sunset
    if [[ "$hour_minute" > "$sunrise_local" && "$hour_minute" < "$sunset_local" ]]; then
        echo "DEBUG: Daytime detected. Turning night vision ON." >> /data/etc/gpio_dyndaynight.log
        echo 1 > /sys/class/gpio/gpio$GPIO/value # Turn night vision OFF (daytime)
    else
        echo "DEBUG: Nighttime detected. Turning night vision OFF." >> /data/etc/gpio_dyndaynight.log
        echo 0 > /sys/class/gpio/gpio$GPIO/value # Turn night vision ON (nighttime)
    fi

    # Sleep for 5 minutes
    sleep 300
done
